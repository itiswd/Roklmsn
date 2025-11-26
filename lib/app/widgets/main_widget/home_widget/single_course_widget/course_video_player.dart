import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/single_course_widget/full_screen_video_player.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/common/utils/download_manager.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../../common/common.dart';

class CourseVideoPlayer extends StatefulWidget {
  final String url;
  final String name;
  final String imageCover;

  final bool isLoadNetwork;
  final String? localFileName;
  final RouteObserver<ModalRoute<void>> routeObserver;

  const CourseVideoPlayer(
    this.url,
    this.imageCover,
    this.routeObserver, {
    this.isLoadNetwork = true,
    this.localFileName,
    super.key,
    required this.name,
  });

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer> with RouteAware {
  // For regular videos
  VideoPlayerController? controller;

  // For YouTube videos
  YoutubePlayerController? _youtubeController;
  bool _isYouTube = false;
  bool _isYouTubePlaying = false;
  bool _showYouTubeControls = true;
  Timer? _hideControlsTimer;
  String? _youtubeVideoId;

  // Quality settings
  String _selectedQuality = 'تلقائي';
  bool _applyBlurEffect = false;
  double _blurSigma = 0.0;
  Timer? _qualityChangeTimer;

  // Playback speed settings
  double _playbackRate = 1.0;

  bool isShowPlayButton = false;
  bool isPlaying = true;

  Duration videoDuration = const Duration(seconds: 0);
  Duration videoPosition = const Duration(seconds: 0);

  bool isShowVideoPlayer = false;

  // Watermark position variables
  double _watermarkPositionX = 0.0;
  double _watermarkPositionY = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initVideo();

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context)!);
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'اختر الجودة',
                  style: style16Bold(),
                ),
              ),
              ...qualities.map((quality) {
                final isSelected = _selectedQuality == quality;
                return ListTile(
                  title: Text(
                    quality,
                    textAlign: TextAlign.center,
                    style: style14Regular().copyWith(
                      color: isSelected ? green63 : grey33,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: green63)
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
      SnackBar(
        content: Text('جاري تغيير الجودة إلى $quality...'),
        duration: const Duration(seconds: 2),
        backgroundColor: green63,
      ),
    );

    // Cancel previous timer if exists
    _qualityChangeTimer?.cancel();

    // Apply blur effect after 4 seconds
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'سرعة التشغيل',
                  style: style16Bold(),
                ),
              ),
              ...playbackRates.map((rate) {
                final isSelected = _playbackRate == rate['value'];
                return ListTile(
                  title: Text(
                    rate['label'] as String,
                    textAlign: TextAlign.center,
                    style: style14Regular().copyWith(
                      color: isSelected ? green63 : grey33,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: green63)
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
    _youtubeController?.setPlaybackRate(rate);

    // Show notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تغيير السرعة إلى ${rate}x'),
        duration: const Duration(seconds: 2),
        backgroundColor: green63,
      ),
    );
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    _timer?.cancel();
    _hideControlsTimer?.cancel();
    _qualityChangeTimer?.cancel();
    controller?.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {
    if (_isYouTube) {
      _youtubeController?.pauseVideo();
    } else {
      controller?.pause();
    }
  }

  @override
  void didPopNext() {
    if (_isYouTube) {
      _youtubeController?.playVideo();
    } else {
      controller?.play();
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
    final patterns = [
      RegExp(
          r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\?\/\s]+)'),
      RegExp(r'youtube\.com\/watch\?.*v=([^&\?\/\s]+)'),
      RegExp(r'youtube\.com\/v\/([^&\?\/\s]+)'),
      RegExp(r'youtube\.com\/shorts\/([^&\?\/\s]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  initVideo() async {
    // Check if it's a YouTube URL
    _isYouTube = widget.isLoadNetwork && _isYoutubeUrl(widget.url);

    if (_isYouTube) {
      // Initialize YouTube player
      await _initializeYouTubePlayer();
    } else if (widget.isLoadNetwork) {
      // Initialize network video
      controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      )..initialize().then((_) {
          isShowVideoPlayer = true;
          controllerListener();
          if (mounted) setState(() {});
          controller?.play();
        });
    } else {
      // Initialize local video file
      String directory = (await getApplicationSupportDirectory()).path;
      debugPrint('${directory.toString()}/${widget.localFileName}');

      bool isExistFile = await DownloadManager.findFile(
        directory,
        widget.localFileName!,
        isOpen: false,
      );

      if (isExistFile) {
        controller = VideoPlayerController.file(
          File('${directory.toString()}/${widget.localFileName}'),
        )..initialize().then((_) {
            isShowVideoPlayer = true;
            controllerListener();
            if (mounted) setState(() {});
            controller?.play();
          });
      }
    }
  }

  Future<void> _initializeYouTubePlayer() async {
    try {
      final videoId = _extractYouTubeId(widget.url);

      if (videoId == null || videoId.isEmpty) {
        throw Exception('Invalid YouTube URL');
      }

      debugPrint('Extracted YouTube ID: $videoId');

      _youtubeVideoId = videoId;

      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
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

      // Listen to YouTube player state
      _youtubeController!.listen((event) {
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

      if (mounted) {
        setState(() {
          isShowVideoPlayer = true;
        });
      }
    } catch (e) {
      debugPrint('YouTube initialization error: $e');
    }
  }

  controllerListener() {
    controller?.addListener(() {
      if (mounted) {
        if (controller!.value.isPlaying) {
          if (!isPlaying) {
            setState(() {
              isPlaying = true;
              isShowPlayButton = true;
            });

            Future.delayed(const Duration(milliseconds: 1500)).then((value) {
              if (mounted) {
                setState(() {
                  isShowPlayButton = false;
                });
              }
            });
          }
        } else {
          if (isPlaying) {
            setState(() {
              isPlaying = false;
              isShowPlayButton = true;
            });

            Future.delayed(const Duration(milliseconds: 1500)).then((value) {
              if (mounted) {
                setState(() {
                  isShowPlayButton = false;
                });
              }
            });
          }
        }

        if (videoPosition.inSeconds != controller!.value.position.inSeconds) {
          log("duration: ${controller!.value.duration.inSeconds.toString()}  position: ${controller!.value.position.inSeconds.toString()}");

          setState(() {
            videoPosition =
                Duration(seconds: controller!.value.position.inSeconds);
          });
        }

        if (videoDuration.inSeconds != controller!.value.duration.inSeconds) {
          setState(() {
            videoDuration =
                Duration(seconds: controller!.value.duration.inSeconds);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // video
          if (isShowVideoPlayer) ...{
            ClipRRect(
              borderRadius: borderRadius(),
              child: _buildVideoWidget(),
            ),

            space(12),

            // Controls for YouTube videos
            if (_isYouTube) ...{
              _buildYouTubeControls(),
            },

            // Controls (only show for non-YouTube videos)
            if (!_isYouTube) ...{
              _buildVideoControls(),
            },
          },
        ],
      ),
    );
  }

  Widget _buildVideoWidget() {
    if (_isYouTube && _youtubeController != null) {
      return _buildYouTubePlayer();
    } else if (controller != null && controller!.value.isInitialized) {
      return _buildRegularVideoPlayer();
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildYouTubePlayer() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
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
        // Overlay to hide channel name (top section)
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
          left: _watermarkPositionX == 0.0
              ? 10
              : (MediaQuery.of(context).size.width / 2) - 50,
          top: _watermarkPositionY == 0.0 ? 10 : 100,
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
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegularVideoPlayer() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),

        // Watermark
        AnimatedPositioned(
          duration: const Duration(seconds: 1),
          left: _watermarkPositionX == 0.0
              ? 0
              : (MediaQuery.of(context).size.width / 2) - 100,
          top: _watermarkPositionY == 0.0 ? 0 : (250 / 2) - 50,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.transparent,
            child: Text(
              widget.name,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // play or pause button
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (isPlaying) {
                controller?.pause();
              } else {
                controller?.play();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: AnimatedOpacity(
                opacity: isShowPlayButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(.3),
                  ),
                  child: Icon(
                    !isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        widget.imageCover,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            AppAssets.placePng,
            width: getSize().width,
            height: getSize().width,
          );
        },
      ),
    );
  }

  Widget _buildYouTubeControls() {
    return Container(
      padding: padding(horizontal: 16, vertical: 16),
      width: getSize().width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius(),
      ),
      child: Column(
        children: [
          // First row: Play/Pause + Quality + Speed
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause button
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (_isYouTubePlaying) {
                      await _youtubeController?.pauseVideo();
                    } else {
                      await _youtubeController?.playVideo();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: green63,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isYouTubePlaying
                              ? Icons.pause
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        space(0, width: 4),
                        Flexible(
                          child: Text(
                            _isYouTubePlaying ? 'إيقاف' : 'تشغيل',
                            style:
                                style14Regular().copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              space(0, width: 8),

              // Quality button
              Expanded(
                child: GestureDetector(
                  onTap: _showQualitySelector,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: blueFE,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.high_quality_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        space(0, width: 4),
                        Flexible(
                          child: Text(
                            'الجودة',
                            style:
                                style14Regular().copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              space(0, width: 8),

              // Speed button
              Expanded(
                child: GestureDetector(
                  onTap: _showPlaybackRateSelector,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.speed,
                          color: Colors.white,
                          size: 22,
                        ),
                        space(0, width: 4),
                        Flexible(
                          child: Text(
                            'السرعة',
                            style:
                                style14Regular().copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          space(12),

          // Second row: Fullscreen button (centered)
          GestureDetector(
            onTap: () async {
              if (_youtubeVideoId == null) return;

              await _youtubeController?.pauseVideo();

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => YouTubeFullscreenPlayer(
                    videoId: _youtubeVideoId!,
                    name: widget.name,
                    watermarkPositionX: _watermarkPositionX,
                    watermarkPositionY: _watermarkPositionY,
                  ),
                ),
              );

              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: greyE7,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.fullscreenSvg,
                    width: 18,
                    height: 18,
                  ),
                  space(0, width: 6),
                  Text(
                    'ملء الشاشة',
                    style: style14Regular().copyWith(color: greyA5),
                  ),
                ],
              ),
            ),
          ),

          // Show current quality
          if (_selectedQuality != 'تلقائي') ...[
            space(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: greyE7,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'الجودة الحالية: $_selectedQuality',
                style: style12Regular().copyWith(color: grey5E),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return AnimatedCrossFade(
      firstChild: Container(
        padding: padding(horizontal: 16, vertical: 16),
        width: getSize().width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // duration and play button
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      controller?.pause();
                    } else {
                      controller?.play();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: greyE7,
                      ),
                    ),
                    child: Icon(
                      !isPlaying ? Icons.play_arrow_rounded : Icons.pause,
                      size: 17,
                    ),
                  ),
                ),
                space(0, width: 16),
                Text(
                  '${secondDurationToString(videoPosition.inSeconds)} / ${secondDurationToString(videoDuration.inSeconds)}',
                  style: style12Regular().copyWith(color: greyB2),
                ),
              ],
            ),

            Row(
              children: [
                // sound
                GestureDetector(
                  onTap: () {
                    if (controller?.value.volume == 0.0) {
                      controller?.setVolume(1.0);
                    } else {
                      controller?.setVolume(0.0);
                    }

                    setState(() {});
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    controller?.value.volume == 0.0
                        ? AppAssets.soundOffSvg
                        : AppAssets.soundOnSvg,
                  ),
                ),

                space(0, width: 22),

                // full screen
                GestureDetector(
                  onTap: () async {
                    controller?.pause();

                    await navigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (context) => FullScreenVideoPlayer(
                          controller!,
                          name: widget.name,
                        ),
                      ),
                    );

                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                    ]);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(AppAssets.fullscreenSvg),
                ),
              ],
            )
          ],
        ),
      ),
      secondChild: SizedBox(width: getSize().width),
      crossFadeState: (controller?.value.isInitialized ?? false)
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
    );
  }
}

// YouTube Fullscreen Player Widget
class YouTubeFullscreenPlayer extends StatefulWidget {
  final String videoId;
  final String name;
  final double watermarkPositionX;
  final double watermarkPositionY;

  const YouTubeFullscreenPlayer({
    super.key,
    required this.videoId,
    required this.name,
    required this.watermarkPositionX,
    required this.watermarkPositionY,
  });

  @override
  State<YouTubeFullscreenPlayer> createState() =>
      _YouTubeFullscreenPlayerState();
}

class _YouTubeFullscreenPlayerState extends State<YouTubeFullscreenPlayer> {
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
        backgroundColor: Colors.green,
      ),
    );

    // Cancel previous timer if exists
    _qualityChangeTimer?.cancel();

    // Apply blur effect after 4 seconds
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
