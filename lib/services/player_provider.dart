import 'package:flutter/material.dart';

///
/// The new State-Manager for Player!
/// Has to be an instance of Singleton to survive
/// over all State-Changes inside chewie
///
class PlayerProvider extends ChangeNotifier {
  PlayerProvider._(
    bool hideStuff,
  ) : _hideStuff = hideStuff;

  bool _hideStuff;

  bool get hideStuff => _hideStuff;

  set hideStuff(bool value) {
    _hideStuff = value;
    notifyListeners();
  }

  // ignore: prefer_constructors_over_static_methods
  static PlayerProvider init([bool hide = true]) {
    return PlayerProvider._(
      hide,
    );
  }
}
