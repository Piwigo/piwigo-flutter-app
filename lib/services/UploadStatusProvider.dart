import 'package:flutter/material.dart';

class UploadStatusNotifier extends ChangeNotifier {
  final String key = "upload_status";
  bool _status;
  int max;
  int current;

  UploadStatusNotifier() {
    _status = false;
    max = 0;
    current = 0;
  }

  double getProgress() {
    return current * 100 / max;
  }
  int getRemaining() {
    return max - current;
  }

  toggleStatus(bool newStatus){
    _status = newStatus;
    notifyListeners();
  }
  bool get status => _status;

}
