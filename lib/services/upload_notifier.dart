import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UploadNotifier extends ChangeNotifier {
  final List<UploadItem> _uploadList = [];
  final List<UploadItem> _uploadHistoryList = [];

  UploadNotifier();

  void addItem(UploadItem item) {
    _uploadList.add(item);
    notifyListeners();
  }

  void addItems(List<UploadItem> item) {
    _uploadList.addAll(item);
    notifyListeners();
  }

  void itemUploadCompleted(UploadItem item, {bool error = false}) {
    _uploadList.remove(item);
    item.error = error;
    _uploadHistoryList.add(item);
    notifyListeners();
  }

  void removeItem(UploadItem item) {
    _uploadList.remove(item);
    notifyListeners();
  }

  void clearHistory() {
    _uploadHistoryList.clear();
  }

  List<UploadItem> get uploadList => _uploadList;
  List<UploadItem> get uploadHistoryList => _uploadHistoryList;
}

class UploadItem {
  final File file;
  final StreamController<double> progress;
  final int albumId;
  final CancelToken cancelToken;
  bool error;

  UploadItem({
    required this.file,
    required this.albumId,
    this.error = false,
    CancelToken? cancelToken,
  })  : progress = StreamController<double>.broadcast(),
        cancelToken = cancelToken ?? CancelToken();
}
