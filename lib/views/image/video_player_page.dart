import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/player_controls.dart';
import 'package:piwigo_ng/services/player_provider.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    Key? key,
    this.videoUrl,
    this.thumbnailUrl,
  }) : super(key: key);

  static const String routeName = '/image/video_player';

  final String? videoUrl;
  final String? thumbnailUrl;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  /// Duration of overlay animation
  final Duration _overlayAnimationDuration = const Duration(milliseconds: 300);

  /// Curve of overlay animation
  final Curve _overlayAnimationCurve = Curves.ease;

  late VideoPlayerController _videoPlayerController;
  late PlayerProvider _provider;
  ChewieController? _chewieController;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    initializePlayer();
    _provider = PlayerProvider.init(true);
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _onToggleOverlay([bool? value]) {
    setState(() {
      if (value != null) {
        _showOverlay = value;
      } else {
        _showOverlay = !_showOverlay;
      }
    });
  }

  Future<void> initializePlayer() async {
    if (widget.videoUrl == null) return;
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl!);
    await _videoPlayerController.initialize();
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      allowFullScreen: false,
      showControlsOnInitialize: true,
      showOptions: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
        handleColor: Colors.white,
      ),
      hideControlsTimer: const Duration(seconds: 3),
      customControls: PlayerControls(onToggleOverlay: _onToggleOverlay),
    )..setVolume(0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null) {
      return Center(
        child: Text(appStrings.errorHUD_label),
      );
    }
    if (_chewieController == null ||
        !_chewieController!.videoPlayerController.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: ChangeNotifierProvider<PlayerProvider>.value(
        value: _provider,
        child: Stack(
          children: [
            Positioned.fill(
              child: Chewie(
                controller: _chewieController!,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: AnimatedSlide(
                duration: _overlayAnimationDuration,
                curve: _overlayAnimationCurve,
                offset: _showOverlay ? Offset.zero : Offset(-1, 0),
                child: AnimatedOpacity(
                  duration: _overlayAnimationDuration,
                  curve: _overlayAnimationCurve,
                  opacity: _showOverlay ? 1 : 0,
                  child: SafeArea(
                    child: IconButton(
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
