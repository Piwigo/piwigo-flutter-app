import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/models/album_model.dart';

class UploadProvider extends ChangeNotifier {
  final List<UploadItem> _uploadList = [];

  UploadProvider();

  void addItem(UploadItem item) {
    _uploadList.add(item);
    notifyListeners();
  }

  void removeItem(UploadItem item) {
    _uploadList.remove(item);
    notifyListeners();
  }

  List<UploadItem> get uploadList => _uploadList;
}

class UploadItem {
  final XFile file;
  final StreamController<double> progress;
  final AlbumModel destination;

  UploadItem({
    required this.file,
    required this.destination,
    required this.progress,
  });
}
