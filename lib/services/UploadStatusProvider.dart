import 'package:flutter/material.dart';

class UploadStatusNotifier extends ChangeNotifier {
  final String key = "upload_status";
  bool _status;
  bool get status => _status;

  UploadStatusNotifier() {
    _status = false;
  }

  toggleStatus(bool newStatus){
    _status = newStatus;
    notifyListeners();
  }
}
