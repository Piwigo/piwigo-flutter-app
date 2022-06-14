import 'package:flutter/material.dart';

class UploadStatusNotifier extends ChangeNotifier {
  final String key = "upload_status";
  bool _status;
  bool get status => _status;
  int _max;
  int get max => _max;
  int _current;
  int get current => _current;
  double _progress;
  double get progress => _progress;


  UploadStatusNotifier() {
    _status = false;
    _max = 0;
    _current = 0;
    _progress = 0.0;
  }

  double getProgress() {
    return _current * 100 / _max;
  }
  String getRemaining() {
    return "$_current/$_max";
  }

  void reset() {
    _max = 0;
    _progress = 0;
    _current = 0;
    _status = false;
  }


  set max(int value) {
    _max = value;
    notifyListeners();
  }

  set progress(double value) {
    _progress = value;
    notifyListeners();
  }

  set status(bool newStatus){
    _status = newStatus;
    notifyListeners();
  }

  set current(int value) {
    _current = value;
    notifyListeners();
  }
}
