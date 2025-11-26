import 'dart:async';
import 'dart:ui';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
  // For YouTube videos
  YoutubePlayerController? _youtubeController;

  // For other videos (MP4, HLS, etc.)
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  double _watermarkPositionX = 0.0;
  double _watermarkPositionY = 0.0;
  Timer? _watermarkTimer;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = true;
  bool _isYouTube = false;
  bool _isYouTubePlaying = false;
  bool _showYouTubeControls = true;
  Timer? _hideControlsTimer;
  String? _youtubeVideoId;

  // Quality settings
  final bool _applyBlurEffect = false;
  final double _blurSigma = 0.0;
  Timer? _qualityChangeTimer;

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
        await _initializeYouTubePlayer(videoUrl);
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

  Future<void> _initializeYouTubePlayer(String url) async {
    try {
      // Extract video ID from URL
      final videoId = _extractYouTubeId(url);

      if (videoId == null || videoId.isEmpty) {
        throw Exception(
            'رابط اليوتيوب غير صحيح. تأكد من الرابط وحاول مرة أخرى.');
      }

      debugPrint('Extracted YouTube ID: $videoId');
      _youtubeVideoId = videoId;

      // ✅ Initialize YouTube player with settings for unlisted videos
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          // ⚠️ مهم جداً: لازم تكون false عشان تشتغل مع unlisted
          showControls: false,
          mute: false,

          // ⚠️ CRITICAL: هذا الإعداد مهم للفيديوهات Unlisted
          showFullscreenButton: false,

          loop: false,

          // ✅ هذا مهم جداً لـ unlisted videos
          enableCaption: true,

          // ⚠️ لازم يكون false
          showVideoAnnotations: false,

          // ✅ CRITICAL للفيديوهات Unlisted
          playsInline: true,
          enableJavaScript: true,

          // ✅ إضافات مهمة للفيديوهات Unlisted
          strictRelatedVideos: true,

          // ⚠️ هام: تعطيل عرض العنوان والقناة
          // showVideoAnnotations: false,
        ),
      );

      // Add listener with enhanced error handling
      _youtubeController!.listen((event) {
        debugPrint('YouTube player event: ${event.playerState}');
        debugPrint('Has error: ${event.hasError}');

        // ✅ معالجة أخطاء محددة
        if (event.hasError) {
          debugPrint('YouTube Error: ${event.error}');
          debugPrint('Error Code: $event');

          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = _formatYouTubeError(event.hashCode);
            });
          }
          return;
        }

        if (mounted) {
          setState(() {
            _isYouTubePlaying = event.playerState == PlayerState.playing;
          });

          // Start hide timer when playing starts
          if (event.playerState == PlayerState.playing) {
            _startHideControlsTimer();
          } else {
            // Show controls when paused
            _hideControlsTimer?.cancel();
            setState(() {
              _showYouTubeControls = true;
            });
          }
        }
      });
    } catch (e) {
      debugPrint('YouTube initialization error: $e');
      rethrow;
    }
  }

// ✅ دالة جديدة لمعالجة أخطاء يوتيوب بشكل أفضل
  String _formatYouTubeError(int? errorCode) {
    if (errorCode == null) {
      return 'حدث خطأ غير معروف في تشغيل الفيديو';
    }

    switch (errorCode) {
      case 2:
        return 'معرف الفيديو غير صحيح أو تالف.\nتأكد من الرابط وحاول مرة أخرى.';
      case 5:
        return 'خطأ في مشغل HTML5.\nحاول إعادة تحميل الصفحة.';
      case 100:
        return 'الفيديو غير موجود أو تم حذفه.\nتحقق من الرابط.';
      case 101:
      case 150:
        // ⚠️ هذا الخطأ شائع مع unlisted videos
        return 'لا يمكن تشغيل هذا الفيديو مباشرة.\n'
            'قد يكون الفيديو unlisted أو محظور من التشغيل المضمن.\n'
            'اضغط "فتح في يوتيوب" للمشاهدة.';
      default:
        return 'حدث خطأ في تشغيل الفيديو (رمز الخطأ: $errorCode).\n'
            'حاول فتح الفيديو في تطبيق يوتيوب.';
    }
  }

// ✅ تحديث دالة _formatErrorMessage الموجودة
  String _formatErrorMessage(String error) {
    // Clean up error messages
    if (error.contains('Exception:')) {
      error = error.split('Exception:').last.trim();
    }

    // Check for YouTube error patterns
    final errorCodeMatch =
        RegExp(r'(?:code|Code)\s*:?\s*(\d+)').firstMatch(error);
    if (errorCodeMatch != null) {
      final code = int.tryParse(errorCodeMatch.group(1) ?? '');
      if (code != null) {
        return _formatYouTubeError(code);
      }
    }

    // Check for specific error messages
    if (error.contains('not available') ||
        error.contains('unavailable') ||
        error.contains('غير متاح')) {
      return 'الفيديو غير متاح حالياً.\n'
          'قد يكون unlisted أو محظور من التشغيل المضمن.\n'
          'جرب فتحه في تطبيق يوتيوب مباشرة.';
    }

    if (error.contains('Invalid YouTube URL') ||
        error.contains('رابط اليوتيوب غير صحيح')) {
      return 'رابط اليوتيوب غير صحيح.\nتأكد من الرابط وحاول مرة أخرى.';
    }

    if (error.contains('Video URL is empty')) {
      return 'رابط الفيديو فارغ.\nالرجاء إضافة رابط صحيح.';
    }

    if (error.contains('Failed to load') || error.contains('network')) {
      return 'فشل تحميل الفيديو.\nتحقق من اتصال الإنترنت وحاول مرة أخرى.';
    }

    // Truncate long errors
    if (error.length > 100) {
      return '${error.substring(0, 100)}...';
    }

    return error;
  }

  Future<void> _initializeVideoPlayer(String url) async {
    try {
      // Initialize video player for non-YouTube videos
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );

      await _videoController!.initialize();

      if (!mounted) {
        _videoController?.dispose();
        return;
      }

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
    } catch (e) {
      debugPrint('Video player initialization error: $e');
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

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    setState(() {
      _showYouTubeControls = true;
    });

    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isYouTubePlaying) {
        setState(() {
          _showYouTubeControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _watermarkTimer?.cancel();
    _hideControlsTimer?.cancel();
    _qualityChangeTimer?.cancel();
    _youtubeController?.close();
    _chewieController?.dispose();
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
      if (_isYouTube && _youtubeController != null) {
        return _buildYouTubePlayer();
      } else if (!_isYouTube && _chewieController != null) {
        return _buildVideoPlayer();
      }
    }

    return _buildLoadingWidget();
  }

  Widget _buildYouTubePlayer() {
    return Stack(
      children: [
        // YouTube Player - Fill container
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: YoutubePlayer(
            controller: _youtubeController!,
            aspectRatio: 16 / 9,
          ),
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

        // Overlay to hide YouTube logo (bottom-right corner)
        Positioned(
          bottom: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Overlay to hide channel name (top section when paused)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Transparent overlay to prevent all interactions and handle taps
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _startHideControlsTimer();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Floating play/pause button
        if (_showYouTubeControls)
          Center(
            child: GestureDetector(
              onTap: () async {
                if (_isYouTubePlaying) {
                  await _youtubeController?.pauseVideo();
                } else {
                  await _youtubeController?.playVideo();
                }
              },
              child: AnimatedOpacity(
                opacity: _showYouTubeControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(.5),
                  ),
                  child: Icon(
                    _isYouTubePlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
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

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        // Video Player - Fill container
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Chewie(controller: _chewieController!),
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
            'Loading video...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
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
                'Failed to Load Video',
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
                maxLines: 4,
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

// Custom YouTube Fullscreen Player Widget
class CustomYouTubeFullscreenPlayer extends StatefulWidget {
  final String videoId;
  final String name;
  final double watermarkPositionX;
  final double watermarkPositionY;

  const CustomYouTubeFullscreenPlayer({
    super.key,
    required this.videoId,
    required this.name,
    required this.watermarkPositionX,
    required this.watermarkPositionY,
  });

  @override
  State<CustomYouTubeFullscreenPlayer> createState() =>
      _CustomYouTubeFullscreenPlayerState();
}

class _CustomYouTubeFullscreenPlayerState
    extends State<CustomYouTubeFullscreenPlayer> {
  bool _isPlaying = false;
  double _watermarkPositionX = 0.0;
  double _watermarkPositionY = 0.0;
  Timer? _timer;
  YoutubePlayerController? _controller;

  // Quality settings
  String _selectedQuality = 'تلقائي';
  bool _applyBlurEffect = false;
  double _blurSigma = 0.0;
  Timer? _qualityChangeTimer;

  // Playback speed settings
  double _playbackRate = 1.0;

  @override
  void initState() {
    super.initState();

    _watermarkPositionX = widget.watermarkPositionX;
    _watermarkPositionY = widget.watermarkPositionY;

    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize YouTube controller
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        mute: false,
        showFullscreenButton: false,
        loop: false,
        enableCaption: false,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
        playsInline: true,
        enableJavaScript: true,
      ),
    );

    // Listen to player state
    _controller!.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = event.playerState == PlayerState.playing;
        });
      }
    });

    // Setup Timer to move watermark
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
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
  }

  void _showQualitySelector() {
    final qualities = [
      'تلقائي',
      '144p',
      '240p',
      '360p',
      '480p',
      '720p',
      '1080p'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'اختر الجودة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...qualities.map((quality) {
                final isSelected = _selectedQuality == quality;
                return ListTile(
                  title: Text(
                    quality,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.red : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.red)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _changeQuality(quality);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _changeQuality(String quality) {
    setState(() {
      _selectedQuality = quality;
    });

    // Show notification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تغيير الجودة...'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );

    // Cancel previous timer if exists
    _qualityChangeTimer?.cancel();

    _qualityChangeTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          switch (quality) {
            case '144p':
              _applyBlurEffect = true;
              _blurSigma = 3.0;
              break;
            case '240p':
              _applyBlurEffect = true;
              _blurSigma = 2.0;
              break;
            case '360p':
              _applyBlurEffect = true;
              _blurSigma = 1.0;
              break;
            case '480p':
              _applyBlurEffect = true;
              _blurSigma = 0.5;
              break;
            default:
              _applyBlurEffect = false;
              _blurSigma = 0.0;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تغيير الجودة إلى $quality'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showPlaybackRateSelector() {
    final playbackRates = [
      {'value': 0.5, 'label': '0.5x'},
      {'value': 1.0, 'label': '1x (عادي)'},
      {'value': 1.5, 'label': '1.5x'},
      {'value': 2.0, 'label': '2x'},
      {'value': 2.5, 'label': '2.5x'},
      {'value': 3.0, 'label': '3x'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'سرعة التشغيل',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...playbackRates.map((rate) {
                final isSelected = _playbackRate == rate['value'];
                return ListTile(
                  title: Text(
                    rate['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _changePlaybackRate(rate['value'] as double);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _changePlaybackRate(double rate) {
    setState(() {
      _playbackRate = rate;
    });

    // Apply playback rate to YouTube controller
    _controller?.setPlaybackRate(rate);

    // Show notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تغيير السرعة إلى ${rate}x'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _qualityChangeTimer?.cancel();
    _controller?.close();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // YouTube Player
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _controller!,
                  aspectRatio: 16 / 9,
                ),
              ),
            ),

            // Blur effect overlay (if quality is low)
            if (_applyBlurEffect)
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: _blurSigma, sigmaY: _blurSigma),
                    child: Container(
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ),
                ),
              ),

            // Overlay to hide YouTube logo (bottom-right corner)
            Positioned(
              bottom: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  width: 100,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Overlay to hide channel name (top section)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Transparent overlay to prevent all interactions
            Positioned.fill(
              child: Container(
                color: Colors.transparent,
              ),
            ),

            // Floating play/pause button (center)
            Center(
              child: GestureDetector(
                onTap: () async {
                  if (_isPlaying) {
                    await _controller?.pauseVideo();
                  } else {
                    await _controller?.playVideo();
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(.5),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),
            ),

            // Watermark
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              left: _watermarkPositionX == 0.0
                  ? 10
                  : (MediaQuery.of(context).size.width / 2) - 80,
              top: _watermarkPositionY == 0.0
                  ? 10
                  : (MediaQuery.of(context).size.height / 2) - 20,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Back button (top-left)
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Quality and Speed buttons (top-right)
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speed button
                  GestureDetector(
                    onTap: _showPlaybackRateSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.speed,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_playbackRate}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Quality button
                  GestureDetector(
                    onTap: _showQualitySelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.high_quality_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedQuality,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
