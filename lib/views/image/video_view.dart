import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/player_controls.dart';
import 'package:piwigo_ng/services/player_provider.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/resources.dart';
import 'package:piwigo_ng/utils/themes.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({
    Key? key,
    this.videoUrl,
    this.thumbnailUrl,
    this.onToggleOverlay,
    this.showOverlay = false,
    this.screenPadding = EdgeInsets.zero,
  }) : super(key: key);

  final String? videoUrl;
  final String? thumbnailUrl;
  final Function(bool)? onToggleOverlay;
  final bool showOverlay;
  final EdgeInsets screenPadding;

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
  bool _isEnd = false;

  /// Initialize video controller
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl!),
      videoPlayerOptions: VideoPlayerOptions(),
    )..initialize().then((_) {
        debugPrint("---- controller initialized");
        _controller.addListener(_onControllerUpdated);
        _controller.addListener(_checkControllerEnd);
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Update video progress
  /// * Listen to [_controller]
  void _onControllerUpdated() async {
    if (!mounted) return;
    // blocking too many updates
    // important !!
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (_updateProgressInterval > now) return;
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
  }

  /// Check and handle video end
  /// * Listen to [_controller]
  void _checkControllerEnd() async {
    if (!mounted) return;
    if (_controller.value.position.inMilliseconds > 0 &&
        _controller.value.position.inSeconds >= _controller.value.duration.inSeconds) {
      setState(() {
        _isEnd = true;
        if (!widget.showOverlay) {
          widget.onToggleOverlay?.call(true);
        }
        setState(() {
          _progress = 1;
        });
      });
    } else {
      if (_isEnd) {
        setState(() {
          _isEnd = false;
        });
      }
    }
  }

  /// Fast rewind action
  /// * Player rewind by 5sec
  Future<void> _onFastRewind() async {
    // Pause player and update overlay
    setState(() {
      _controller.pause();
    });
    // Rewind 5sec on the player
    await _controller.seekTo(_controller.value.position - Duration(seconds: 5));
    // Resume player and update overlay
    setState(() {
      _controller.play();
    });
  }

  /// Play / pause action
  /// * If playing: pause the video
  /// * Otherwise: resume / play the video
  void _onPlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  /// Fast forward action
  /// * Player forward by 5sec
  Future<void> _onFastForward() async {
    // Pause player and update overlay
    setState(() {
      _controller.pause();
    });
    // Rewind 5sec on the player
    await _controller.seekTo(_controller.value.position + Duration(seconds: 5));
    setState(() {
      // Resume player and update overlay if didn't reached the end
      if (!_isEnd) {
        _controller.play();
      }
    });
  }

  /// Replay action
  void _onReplay() {
    setState(() {
      _controller.play();
    });
  }

  /// Mute / Un-mute action
  /// * Switches [_controller] volume from 0 (mute) to 1 (un-mute)
  void _onMute() {
    final double volume = _mute ? 1.0 : 0.0;
    setState(() {
      _controller.setVolume(volume);
      _mute = !_mute;
    });
  }

  /// Update [_progress] when time changed
  void _onVideoTimeChanged(double value) {
    setState(() {
      _progress = value * 0.01;
    });
  }

  /// Pauses video player [_controller] while changing time
  void _onVideoTimeChangeStart(double value) {
    setState(() {
      _controller.pause();
    });
  }

  /// Update video player [_controller] when time changed
  Future<void> _onVideoTimeChangeEnd(double value) async {
    // Parse slider time
    final double newValue = max(0, min(value, 99)) * 0.01;
    final int millis = (_controller.value.duration.inMilliseconds * newValue).toInt();
    // Change time
    await _controller.seekTo(Duration(milliseconds: millis));
    // Resume player
    setState(() {
      _controller.play();
    });
  }

  /// Get parsed video duration text.
  /// * If paused: returns video duration.
  /// * If playing: returns video remaining time.
  String get _durationText {
    late final Duration duration;
    if (!_controller.value.isPlaying) {
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
      return Stack(
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
      );
    });
  }

  /// Video player overlay
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

  /// Video player center overlay
  /// * Fast rewind
  /// * Play / Pause / Replay
  /// * Fast forward
  Widget get _overlayCenter {
    // Check if the player is processing / loading.
    if ((_controller.value.isBuffering && !_isEnd) || (_isEnd && _controller.value.isPlaying)) {
      return Center(child: CircularProgressIndicator());
    }
    // If player has ended, show the replay button
    if (_isEnd && !_controller.value.isPlaying) {
      return Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onReplay,
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
    // Video player is playing
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onFastRewind,
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
          onTap: _onPlayPause,
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
          onTap: _onFastForward,
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

  /// Video player bottom overlay
  /// * Duration
  /// * Timeline
  /// * Mute / Un-mute
  Widget get _overlayBottom {
    return Positioned(
      bottom: widget.screenPadding.bottom,
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
                child: Theme(
                  // Light slider theme
                  data: lightTheme,
                  child: Slider(
                    value: _isEnd ? 100 : max(0, min(_progress * 100, 100)),
                    min: 0,
                    max: 100,
                    onChanged: _onVideoTimeChanged,
                    onChangeStart: _onVideoTimeChangeStart,
                    onChangeEnd: _onVideoTimeChangeEnd,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onMute,
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

  /// Video player overlay's background color
  Widget get _overlayBackground {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
      ),
    );
  }

  /// Video thumbnail shown when loading
  Widget get _thumbnail {
    // Thumbnail doesn't exist
    if (widget.thumbnailUrl == null) {
      return Center(
        child: Icon(Icons.image_not_supported),
      );
    }
    return Stack(
      children: [
        // Thumbnail
        Positioned.fill(
          child: Image.network(
            widget.thumbnailUrl!,
            fit: BoxFit.contain,
            errorBuilder: (context, o, s) {
              debugPrint("$o");
              return Center(child: Icon(Icons.image_not_supported));
            },
          ),
        ),
        // Loading...
        if (!_controller.value.isInitialized) Center(child: CircularProgressIndicator()),
        // Error while loading the video
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

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView(
      {Key? key,
      this.videoUrl,
      this.thumbnailUrl,
      this.onToggleOverlay,
      this.showOverlay = false,
      this.screenPadding = EdgeInsets.zero})
      : super(key: key);

  final String? videoUrl;
  final String? thumbnailUrl;
  final Function(bool)? onToggleOverlay;
  final bool showOverlay;
  final EdgeInsets screenPadding;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  late PlayerProvider _provider;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
    _provider = PlayerProvider.init(widget.showOverlay);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    if (widget.videoUrl == null) return;
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    await _videoPlayerController.initialize();
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      allowFullScreen: false,
      showOptions: false,
      hideControlsTimer: const Duration(seconds: 3),
      customControls: PlayerControls(onToggleOverlay: widget.onToggleOverlay),
    )..setVolume(0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null) {
      return Center(
        child: Text(appStrings.errorHUD_label),
      );
    }
    if (_chewieController == null || !_chewieController!.videoPlayerController.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ChangeNotifierProvider<PlayerProvider>.value(
      value: _provider,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}
