import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcVideoPlayer extends StatefulWidget {
  const VlcVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
  });
  final String videoUrl;
  final String? thumbnailUrl;

  static const String routeName = '/image/video_player';

  @override
  State<StatefulWidget> createState() => VlcVideoPlayerState();
}

class VlcVideoPlayerState extends State<VlcVideoPlayer> {
  late VlcPlayerController vlcController;
  late Duration videoDuration;
  late Duration videoPosition;
  double opacityLevel = 0.0; // Start with controls faded out

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    print(widget.videoUrl);
    vlcController = VlcPlayerController.network(
      widget.videoUrl,
      hwAcc: HwAcc.auto,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
    videoDuration = Duration(seconds: 0); // Pre init duration is null
    videoPosition = Duration(seconds: 0);
    vlcController.addListener(() {
      // Only update if it's visible
      if (vlcController.value.isInitialized || opacityLevel != 0) {
        setState(() {
          videoDuration = vlcController.value.duration;
          videoPosition = vlcController.value.position;
        });
      }
    });
  }

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0.0 ? 1.0 : 0.0);
  }

  // Convert a Duration to h:mm:ss / mm:ss String format
  String formatDuration(Duration d) {
    var prettyDuration = (d.inHours > 1 ? "${d.inHours}:" : '');
    prettyDuration += "${d.inMinutes % 60 < 10 ? "0" : ''}${d.inMinutes % 60}:";
    prettyDuration += "${d.inSeconds % 60 < 10 ? "0" : ''}${d.inSeconds % 60}";
    return prettyDuration;
  }

  Future<void> _mediaAction() async {
    switch (vlcController.value.playingState) {
      case PlayingState.stopped || PlayingState.ended:
        await vlcController.stop().then((_) => vlcController.play());
        _changeOpacity();
      case PlayingState.paused:
        await vlcController.play();
        _changeOpacity();
      case PlayingState.playing || PlayingState.buffering:
        await vlcController.pause();
        setState(() {});
      case _: // handle all other cases
        {}
    }
  }

  @override
  Future<void> dispose() async {
    // Reset fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
    // Also dispose VLC controller
    await vlcController.stopRendererScanning();
    await vlcController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          VlcPlayer(
            controller: vlcController,
            placeholder: Center(child: CircularProgressIndicator()),
            aspectRatio: screenSize.width / screenSize.height,
          ),
          // Detect any tap to show or hide controls
          GestureDetector(onTap: _changeOpacity),
          IgnorePointer(
            // Ignore input when not visible
            ignoring: opacityLevel == 0.0,
            child: AnimatedOpacity(
              opacity: opacityLevel,
              duration: Duration(milliseconds: 250), // Magic number :(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(top: 8),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded( // Media button
                    child: Center(
                      child: IconButton(
                        onPressed: _mediaAction,
                        icon: Icon(
                          switch (vlcController.value.playingState) {
                            PlayingState.playing => Icons.pause,
                            PlayingState.paused => Icons.play_arrow,
                            PlayingState.stopped => Icons.replay,
                            PlayingState.error => Icons.error,
                            _ => Icons.play_arrow,
                          },
                          size: 85, // Magic number :(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Row( // Bottom controls and seekbar
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _mediaAction,
                        icon: Icon(switch (vlcController.value.playingState) {
                          PlayingState.playing => Icons.pause,
                          PlayingState.paused => Icons.play_arrow,
                          PlayingState.stopped => Icons.replay,
                          PlayingState.error => Icons.error,
                          _ => Icons.play_arrow,
                        }, color: Colors.white),
                      ),
                      Text( // May cause issue if video is hour long
                        formatDuration(videoPosition),
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded( // Seekbar
                        child: Slider(
                          value: videoPosition.inSeconds.toDouble(),
                          max: videoDuration.inSeconds.toDouble(),
                          onChanged: (nv) {
                            setState(() {  //convert to Milliseconds since VLC requires ms
                              vlcController.setTime(
                                nv.toInt() * Duration.millisecondsPerSecond,
                              );
                            });
                          },
                        ),
                      ),
                      Text( // May cause issue if video is hour long
                        formatDuration(videoDuration),
                        style: TextStyle(color: Colors.white),
                      ),
                      IconButton( // volume on/off
                        onPressed: () {
                          vlcController.setVolume(
                            vlcController.value.volume == 0 ? 100 : 0,
                          );
                        },
                        icon: Icon(
                          vlcController.value.volume != 0
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
