
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerViewPage extends StatefulWidget {
  const VideoPlayerViewPage(this.url, {Key key, this.ratio = 1}) : super(key: key);

  final url;
  final ratio;

  @override
  _VideoPlayerViewPageState createState() => _VideoPlayerViewPageState();
}

class _VideoPlayerViewPageState extends State<VideoPlayerViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.chevron_left),
          ),
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent
      ),
      body: Container(
        child: Center(
          child: BetterPlayer.network(
            widget.url,
            betterPlayerConfiguration: BetterPlayerConfiguration(
              fit: BoxFit.contain,
              aspectRatio: widget.ratio,
              fullScreenAspectRatio: widget.ratio,
              autoPlay: true,
              autoDispose: true,
              controlsConfiguration: BetterPlayerControlsConfiguration(
                enableSkips: false,
                enableFullscreen: false,
                enableAudioTracks: false,
                enableMute: false,
                unMuteIcon: Icons.volume_off,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
