import 'dart:async';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PodVideoPlayerDev extends StatefulWidget {
  final String type;
  final String url;
  final String name;
  final RouteObserver<ModalRoute<void>> routeObserver;

  const PodVideoPlayerDev(
    this.url,
    this.type,
    this.routeObserver, {
    super.key,
    required this.name,
  });

  @override
  State<PodVideoPlayerDev> createState() => _VimeoVideoPlayerState();
}

class _VimeoVideoPlayerState extends State<PodVideoPlayerDev> {
  // For video player (using video_player + youtube_explode_dart)
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  final YoutubeExplode _youtubeExplode = YoutubeExplode();

  // For YouTube Player Flutter (fallback for embedding disabled videos)
  YoutubePlayerController? _youtubePlayerController;
  bool _useYoutubePlayer = false;

  double _watermarkPositionX = 0.0;
  double _watermarkPositionY = 0.0;
  Timer? _watermarkTimer;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = true;
  bool _isYouTube = false;
  String? _youtubeVideoId;
  String? _videoTitle;

  // Quality settings
  final bool _applyBlurEffect = false;
  final double _blurSigma = 0.0;

  final _headsetPlugin = HeadsetEvent();
  HeadsetState? _headsetState;

  @override
  void initState() {
    super.initState();

    // Request Permissions (Required for Android 12)
    _headsetPlugin.requestPermission();

    // Check if headset is plugged
    _headsetPlugin.getCurrentState.then((val) {
      if (mounted) {
        setState(() {
          _headsetState = val;
          debugPrint("Headset state initialized: $_headsetState");
        });
      }
    });

    // Detect the moment headset is plugged or unplugged
    _headsetPlugin.setListener((val) {
      if (mounted) {
        setState(() {
          _headsetState = val;
          debugPrint("Headset state changed: $_headsetState");
        });
      }
    });

    // Initialize the video player
    _initializePlayer();

    // Setup Timer to move watermark every 3 seconds
    _watermarkTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          if (_watermarkPositionX == 0.0 && _watermarkPositionY == 0.0) {
            _watermarkPositionX = 0.5;
            _watermarkPositionY = 0.5;
          } else {
            _watermarkPositionX = 0.0;
            _watermarkPositionY = 0.0;
          }
        });
      }
    });

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> _initializePlayer() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _useYoutubePlayer = false;
    });

    try {
      String videoUrl = widget.url.trim();

      // Validate URL
      if (videoUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }

      // Check if it's a YouTube URL
      _isYouTube = _isYoutubeUrl(videoUrl);

      if (_isYouTube) {
        debugPrint('YouTube URL detected: $videoUrl');
        await _initializeYouTubeVideoPlayer(videoUrl);
      } else {
        debugPrint('Direct URL detected: $videoUrl');
        await _initializeVideoPlayer(videoUrl);
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing player: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = _formatErrorMessage(e.toString());
        });
      }
    }
  }

  Future<void> _initializeYouTubeVideoPlayer(String url) async {
    try {
      // Extract video ID from URL
      final videoId = _extractYouTubeId(url);

      if (videoId == null || videoId.isEmpty) {
        throw Exception(
            'رابط اليوتيوب غير صحيح. تأكد من الرابط وحاول مرة أخرى.');
      }

      debugPrint('🎬 Extracted YouTube ID: $videoId');
      _youtubeVideoId = videoId;

      // ✅ Get video info first
      Video? video;
      try {
        video = await _youtubeExplode.videos.get(videoId);
        setState(() {
          _videoTitle = video?.title;
        });
        debugPrint('✅ Video title: ${video.title}');
      } catch (e) {
        debugPrint('⚠️ Could not fetch video info: $e');
        // Continue anyway, we'll try to get the stream
      }

      // ✅ Get stream manifest with better error handling
      StreamManifest manifest;
      try {
        manifest =
            await _youtubeExplode.videos.streamsClient.getManifest(videoId);
        debugPrint('✅ Manifest fetched successfully');
      } catch (e) {
        debugPrint('❌ Failed to get manifest: $e');

        // Check if it's an embedding disabled error
        if (e.toString().contains('unplayable') ||
            e.toString().contains('embedding') ||
            e.toString().contains('Video is unavailable') ||
            e.toString().contains('not available')) {
          debugPrint('🔄 Switching to YouTube Player (embedding disabled)');
          await _initializeYouTubePlayerFallback(videoId);
          return;
        }

        throw Exception(
            'فشل في جلب معلومات الفيديو. قد يكون الفيديو غير متاح أو محمي.');
      }

      // ✅ Try different stream types in order of preference
      String? streamUrl;

      // 1. Try muxed streams first (best quality with audio+video)
      try {
        if (manifest.muxed.isNotEmpty) {
          final muxedStream = manifest.muxed.withHighestBitrate();
          streamUrl = muxedStream.url.toString();
          debugPrint('✅ Using muxed stream: ${muxedStream.qualityLabel}');
        }
      } catch (e) {
        debugPrint('⚠️ Muxed stream failed: $e');
      }

      // 2. If muxed failed, try video-only streams
      if (streamUrl == null) {
        try {
          if (manifest.videoOnly.isNotEmpty) {
            final videoStream = manifest.videoOnly.withHighestBitrate();
            streamUrl = videoStream.url.toString();
            debugPrint(
                '⚠️ Using video-only stream (no audio): ${videoStream.qualityLabel}');
          }
        } catch (e) {
          debugPrint('⚠️ Video-only stream failed: $e');
        }
      }

      // 3. If all failed, try audio-only as last resort
      if (streamUrl == null) {
        try {
          if (manifest.audioOnly.isNotEmpty) {
            final audioStream = manifest.audioOnly.withHighestBitrate();
            streamUrl = audioStream.url.toString();
            debugPrint('⚠️ Using audio-only stream: ${audioStream.bitrate}');
          }
        } catch (e) {
          debugPrint('❌ Audio-only stream failed: $e');
        }
      }

      if (streamUrl == null) {
        debugPrint('🔄 No stream available, switching to YouTube Player');
        await _initializeYouTubePlayerFallback(videoId);
        return;
      }

      debugPrint('🎥 Final stream URL: $streamUrl');

      // Initialize video player with the stream URL
      await _initializeVideoPlayer(streamUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ تم تحميل: ${_videoTitle ?? "فيديو يوتيوب"}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ YouTube initialization error: $e');
      debugPrint('Stack trace: $stackTrace');

      // Last resort: try YouTube Player
      if (_youtubeVideoId != null) {
        debugPrint('🔄 Final fallback to YouTube Player');
        try {
          await _initializeYouTubePlayerFallback(_youtubeVideoId!);
          return;
        } catch (fallbackError) {
          debugPrint('❌ YouTube Player fallback also failed: $fallbackError');
        }
      }

      rethrow;
    }
  }

  Future<void> _initializeYouTubePlayerFallback(String videoId) async {
    try {
      debugPrint('📺 Initializing YouTube Player for video: $videoId');

      // Dispose previous controllers
      _videoController?.dispose();
      _videoController = null;
      _chewieController?.dispose();
      _chewieController = null;
      _youtubePlayerController?.dispose();
      _youtubePlayerController = null;

      if (!mounted) return;

      // Set loading state first
      setState(() {
        _useYoutubePlayer = true;
        _isInitialized = false;
        _isLoading = true;
        _hasError = false;
      });

      // Wait a bit for disposal
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // Initialize YouTube Player Controller with better flags
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          controlsVisibleAtStart: true,
          hideControls: false,
          isLive: false,
          forceHD: false,
          loop: false,
          disableDragSeek: false,
          useHybridComposition: true, // Important for Android
        ),
      );

      // Add listener to track player state
      _youtubePlayerController!.addListener(() {
        if (mounted) {
          final isPlaying = _youtubePlayerController!.value.isPlaying;
          final isReady = _youtubePlayerController!.value.isReady;

          debugPrint(
              'YouTube Player State - Ready: $isReady, Playing: $isPlaying');

          if (isReady && _isLoading) {
            setState(() {
              _isInitialized = true;
              _isLoading = false;
              _hasError = false;
            });
            debugPrint('✅ YouTube Player is now ready and initialized');
          }
        }
      });

      debugPrint(
          '✅ YouTube Player controller created, waiting for ready state...');
    } catch (e) {
      debugPrint('❌ YouTube Player initialization failed: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = 'فشل تحميل مشغل اليوتيوب: $e';
        });
      }
    }
  }

  Future<void> _initializeVideoPlayer(String url) async {
    try {
      debugPrint('🎬 Initializing video player with URL: $url');

      // Dispose previous controller if exists
      _videoController?.dispose();
      _chewieController?.dispose();
      _youtubePlayerController?.dispose();

      // Initialize video player
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      await _videoController!.initialize();

      if (!mounted) {
        _videoController?.dispose();
        return;
      }

      debugPrint('✅ Video player initialized successfully');

      // Initialize Chewie controller for better UI controls
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.white30,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
              strokeWidth: 3,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                const Text(
                  'Playback Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _useYoutubePlayer = false;
      });

      debugPrint('✅ Chewie controller initialized successfully');
    } catch (e) {
      debugPrint('❌ Video player initialization error: $e');
      rethrow;
    }
  }

  bool _isYoutubeUrl(String url) {
    final youtubePatterns = [
      'youtube.com',
      'youtu.be',
      'm.youtube.com',
      'www.youtube.com',
    ];

    return youtubePatterns
        .any((pattern) => url.toLowerCase().contains(pattern));
  }

  String? _extractYouTubeId(String url) {
    try {
      // Clean the URL
      url = url.trim();

      // Handle different YouTube URL formats
      final patterns = [
        // Standard watch URL: https://www.youtube.com/watch?v=VIDEO_ID
        RegExp(r'(?:youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})'),

        // Short URL: https://youtu.be/VIDEO_ID
        RegExp(r'(?:youtu\.be\/)([a-zA-Z0-9_-]{11})'),

        // Embed URL: https://www.youtube.com/embed/VIDEO_ID
        RegExp(r'(?:youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})'),

        // Shorts URL: https://www.youtube.com/shorts/VIDEO_ID
        RegExp(r'(?:youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})'),

        // V parameter URL: https://www.youtube.com/v/VIDEO_ID
        RegExp(r'(?:youtube\.com\/v\/)([a-zA-Z0-9_-]{11})'),

        // Watch URL with additional parameters
        RegExp(r'(?:youtube\.com\/watch\?.*v=)([a-zA-Z0-9_-]{11})'),

        // Mobile URL
        RegExp(r'(?:m\.youtube\.com\/watch\?v=)([a-zA-Z0-9_-]{11})'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(url);
        if (match != null && match.groupCount >= 1) {
          final videoId = match.group(1);
          if (videoId != null && videoId.length == 11) {
            debugPrint(
                'Successfully extracted YouTube ID: $videoId from URL: $url');
            return videoId;
          }
        }
      }

      debugPrint('Failed to extract YouTube ID from URL: $url');
      return null;
    } catch (e) {
      debugPrint('Error extracting YouTube ID: $e');
      return null;
    }
  }

  Future<void> _openYouTubeVideo() async {
    if (_youtubeVideoId == null) return;

    final url = 'https://www.youtube.com/watch?v=$_youtubeVideoId';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح الفيديو'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening YouTube video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في فتح الفيديو: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatErrorMessage(String error) {
    // Clean up error messages
    if (error.contains('Exception:')) {
      error = error.split('Exception:').last.trim();
    }

    // Check for specific error messages
    if (error.contains('not available') ||
        error.contains('unavailable') ||
        error.contains('غير متاح')) {
      return 'الفيديو غير متاح حالياً.\n'
          'قد يكون محظور من التشغيل المضمن.\n'
          'جرب فتحه في تطبيق يوتيوب مباشرة.';
    }

    if (error.contains('Invalid YouTube URL') ||
        error.contains('رابط اليوتيوب غير صحيح')) {
      return 'رابط اليوتيوب غير صحيح.\nتأكد من الرابط وحاول مرة أخرى.';
    }

    if (error.contains('Video URL is empty')) {
      return 'رابط الفيديو فارغ.\nالرجاء إضافة رابط صحيح.';
    }

    if (error.contains('Failed to load') ||
        error.contains('network') ||
        error.contains('failed to fetch') ||
        error.contains('VideoUnplayableException')) {
      return 'فشل تحميل الفيديو.\n'
          'تحقق من اتصال الإنترنت أو قد يكون الفيديو محظور.';
    }

    if (error.contains('No stream available') ||
        error.contains('لم يتم العثور')) {
      return 'لم يتم العثور على stream متاح للتشغيل.\n'
          'قد يكون الفيديو محمي أو غير متاح في منطقتك.';
    }

    // Truncate long errors
    if (error.length > 100) {
      return '${error.substring(0, 100)}...';
    }

    return error;
  }

  @override
  void dispose() {
    _watermarkTimer?.cancel();
    _youtubeExplode.close();
    _youtubePlayerController?.pause();
    _youtubePlayerController?.dispose();
    _chewieController?.pause();
    _chewieController?.dispose();
    _videoController?.pause();
    _videoController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 250,
                width: MediaQuery.of(context).size.width,
                color: Colors.black,
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_isInitialized) {
      if (_useYoutubePlayer && _youtubePlayerController != null) {
        return _buildYouTubePlayer();
      } else if (_chewieController != null) {
        return _buildVideoPlayer();
      }
    }

    return _buildLoadingWidget();
  }

  Widget _buildYouTubePlayer() {
    if (_youtubePlayerController == null) {
      return _buildLoadingWidget();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        children: [
          // YouTube Player - Fill container with YoutubePlayerBuilder for better lifecycle
          YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _youtubePlayerController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
                backgroundColor: Colors.grey,
                bufferedColor: Colors.white70,
              ),
              aspectRatio: 16 / 9,
              onReady: () {
                debugPrint('✅ YouTube Player onReady callback triggered');
                if (mounted && _isLoading) {
                  setState(() {
                    _isInitialized = true;
                    _isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ جاهز للتشغيل'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              onEnded: (metadata) {
                debugPrint('Video ended');
              },
            ),
            builder: (context, player) {
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: player,
              );
            },
          ),

          // Show loading overlay while initializing
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'جاري تحميل الفيديو...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Watermark
          if (!_isLoading)
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              left: _watermarkPositionX == 0.0
                  ? 10
                  : (MediaQuery.of(context).size.width / 2) - 50,
              top: _watermarkPositionY == 0.0 ? 10 : (250 / 2) - 20,
              child: IgnorePointer(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        // Video Player - Fill container
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Chewie(controller: _chewieController!),
        ),

        // Blur effect overlay (if quality is low)
        if (_applyBlurEffect)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
                child: Container(
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
            ),
          ),

        // Watermark
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          left: _watermarkPositionX == 0.0
              ? 10
              : (MediaQuery.of(context).size.width / 2) - 50,
          top: _watermarkPositionY == 0.0 ? 10 : (250 / 2) - 20,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.name,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.red,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الفيديو...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          if (_videoTitle != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _videoTitle!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),
              const Text(
                'فشل تحميل الفيديو',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _initializePlayer();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  // Add YouTube button if it's a YouTube video
                  if (_isYouTube && _youtubeVideoId != null) ...{
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _openYouTubeVideo,
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: const Text('فتح في يوتيوب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
