import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime_type/mime_type.dart';
import 'package:piwigo_ng/api/albums.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/resources.dart';
import 'package:video_player/video_player.dart';

class ImageViewPage extends StatefulWidget {
  const ImageViewPage({
    Key? key,
    this.imageList = const [],
    this.startId,
    this.album,
  }) : super(key: key);

  static const String routeName = '/album/image';

  final List<ImageModel> imageList;
  final String? startId;
  final AlbumModel? album;

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  final Duration _overlayAnimationDuration = const Duration(milliseconds: 300);
  final Curve _overlayAnimationCurve = Curves.ease;
  late final PageController _pageController;
  bool _showOverlay = true;
  int _page = 0;

  @override
  void initState() {
    final ImageModel? startImage = widget.imageList.firstWhere((image) => image.id == widget.startId);
    if (startImage != null) {
      _page = widget.imageList.indexOf(startImage);
    }
    _pageController = PageController(initialPage: _page);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onToggleOverlay() {
    if (_showOverlay) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: [SystemUiOverlay.top]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);
    }
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        extendBody: true,
        primary: false,
        body: Container(
          color: Colors.green,
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() {
                    _page = page;
                  }),
                  itemCount: widget.imageList.length,
                  itemBuilder: (context, index) {
                    final ImageModel image = widget.imageList[index];
                    String? mimeType = mime(image.file);
                    if (mimeType != null && mimeType.startsWith('video')) {
                      return VideoView(
                        videoUrl: image.elementUrl ?? '',
                        thumbnailUrl: image.derivatives.medium.url,
                        showOverlay: _showOverlay,
                        onToggleOverlay: _onToggleOverlay,
                      );
                    }
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _onToggleOverlay,
                      child: Image.network(
                        image.derivatives.medium.url,
                        fit: BoxFit.scaleDown,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: AnimatedSlide(
                  duration: _overlayAnimationDuration,
                  curve: _overlayAnimationCurve,
                  offset: _showOverlay ? Offset.zero : Offset(0, -1),
                  child: Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.arrow_back),
                          ),
                          Expanded(
                            child: Text(
                              '${widget.imageList[_page].name}',
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoView extends StatefulWidget {
  const VideoView({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.onToggleOverlay,
    this.showOverlay = false,
  }) : super(key: key);

  final String videoUrl;
  final String? thumbnailUrl;
  final Function()? onToggleOverlay;
  final bool showOverlay;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  final Duration _overlayAnimationDuration = const Duration(milliseconds: 300);
  final Curve _overlayAnimationCurve = Curves.ease;
  late VideoPlayerController _controller;
  double _progress = 0;
  double _updateProgressInterval = 0.0;
  bool _mute = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.videoUrl,
      videoPlayerOptions: VideoPlayerOptions(),
    )..initialize().then((_) {
        debugPrint("---- controller initialized");
        _controller.addListener(_onControllerUpdated);
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdated() async {
    if (!mounted) return;
    // blocking too many updates
    // important !!
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (_updateProgressInterval > now) {
      return;
    }
    _updateProgressInterval = now + 300.0;

    final VideoPlayerController controller = _controller;

    if (!controller.value.isInitialized) return;

    // handle progress indicator
    if (controller.value.isPlaying) {
      final Duration position = controller.value.position;
      if (!mounted) return;
      setState(() {
        _progress = position.inMilliseconds.ceilToDouble() / controller.value.duration.inMilliseconds.ceilToDouble();
      });
    }

    // handle clip end
    if (_isEnd) {
      if (!mounted) return;
      setState(() {
        _progress = 1;
      });
    }
  }

  bool get _isEnd {
    return _controller.value.position.inMilliseconds > 0 &&
        _controller.value.position.inSeconds + 1 >= _controller.value.duration.inSeconds;
  }

  String get _durationText {
    late final Duration duration;
    if (!_controller.value.isPlaying && !_isEnd) {
      duration = _controller.value.duration;
    } else {
      duration = _controller.value.duration - _controller.value.position;
    }
    int hours = duration.inHours;
    int minutes = (duration - Duration(hours: hours)).inMinutes;
    int seconds = (duration - Duration(hours: hours) - Duration(minutes: minutes)).inSeconds;
    return '${hours > 0 ? '$hours:' : ''}${minutes < 10 ? '0$minutes' : '$minutes'}:${seconds < 10 ? '0$seconds' : '$seconds'}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized || _controller.value.hasError) {
      return _thumbnail;
    }
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggleOverlay,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
            _overlay,
          ],
        ),
      );
    });
  }

  Widget get _overlay {
    return IgnorePointer(
      ignoring: !widget.showOverlay,
      child: AnimatedOpacity(
        duration: _overlayAnimationDuration,
        curve: _overlayAnimationCurve,
        opacity: widget.showOverlay ? 1 : 0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _overlayBackground,
            _overlayCenter,
            _overlayBottom,
          ],
        ),
      ),
    );
  }

  Widget get _overlayCenter {
    if ((_controller.value.isBuffering && !_isEnd) || (_isEnd && _controller.value.isPlaying)) {
      return Center(child: CircularProgressIndicator());
    }
    if (_isEnd && !_controller.value.isPlaying) {
      return Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _controller.play();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.replay,
              size: 48,
              color: Colors.white,
              shadows: AppShadows.icon,
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            setState(() {
              _controller.pause();
            });
            await _controller.seekTo(_controller.value.position - Duration(seconds: 5));
            setState(() {
              if (!_isEnd) {
                _controller.play();
              } else {
                _progress = 1;
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.fast_rewind,
              size: 40,
              color: Colors.white,
              shadows: AppShadows.icon,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 64,
              color: Colors.white,
              shadows: AppShadows.icon,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            setState(() {
              _controller.pause();
            });
            await _controller.seekTo(_controller.value.position + Duration(seconds: 5));
            setState(() {
              if (!_isEnd) {
                _controller.play();
              } else {
                _progress = 1;
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.fast_forward,
              size: 40,
              color: Colors.white,
              shadows: AppShadows.icon,
            ),
          ),
        ),
      ],
    );
  }

  Widget get _overlayBottom {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: AnimatedSlide(
        duration: _overlayAnimationDuration,
        curve: _overlayAnimationCurve,
        offset: widget.showOverlay ? Offset.zero : Offset(0, 1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _durationText,
                  style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _isEnd ? 100 : max(0, min(_progress * 100, 100)),
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      _progress = value * 0.01;
                    });
                  },
                  onChangeStart: (value) {
                    _controller.pause();
                  },
                  onChangeEnd: (value) {
                    final double newValue = max(0, min(value, 99)) * 0.01;
                    final int millis = (_controller.value.duration.inMilliseconds * newValue).toInt();
                    _controller.seekTo(Duration(milliseconds: millis));
                    _controller.play();
                  },
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final double volume = _mute ? 1.0 : 0.0;
                  setState(() {
                    _controller.setVolume(volume);
                    _mute = !_mute;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    _mute ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _overlayBackground {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
      ),
    );
  }

  Widget get _thumbnail {
    if (widget.thumbnailUrl == null) {
      return Center(
        child: Icon(Icons.image_not_supported),
      );
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            widget.thumbnailUrl!,
            fit: BoxFit.contain,
          ),
        ),
        if (!_controller.value.isInitialized) Center(child: CircularProgressIndicator()),
        if (_controller.value.hasError)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black.withOpacity(0.5),
              ),
              child: Text(
                appStrings.videoLoadError_message,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
