import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ImmersiveScrollListener {
  static void function(
    ScrollController controller, [
    List<SystemUiOverlay> enabledOverlays = const <SystemUiOverlay>[],
  ]) {
    if (controller.position.userScrollDirection == ScrollDirection.reverse) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: enabledOverlays);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
