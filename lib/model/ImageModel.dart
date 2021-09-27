import 'package:piwigo_ng/model/DerivativeModel.dart';

class ImageModel {
  int _id;
  int _width;
  int _height;
  int _hit;
  String _file;
  String _name;
  String _comment;
  String _creationDate;
  String _availableDate;
  String _pageUrl;
  String _elementUrl;
  Map<String, DerivativeModel> _derivatives;

  ImageModel(this._id,
    this._file,
    this._name,
    this._comment,
    this._elementUrl,
    this._derivatives,
    {
      width,
      height,
      availableDate,
      creationDate,
      hit,
      pageUrl
    }
  ) {
    _width = width ?? 0;
    _height = height ?? 0;
    _availableDate = availableDate ?? '';
    _creationDate = creationDate ?? '';
    _hit = hit ?? 0;
    _pageUrl = pageUrl ?? '';
  }

  ImageModel.fromJson(Map<String, dynamic> json) :
    _id = json['id'],
    _width = json['width'],
    _height = json['height'],
    _hit = json['hit'],
    _file = json['file'],
    _name = json[''],
    _comment = json['comment'],
    _creationDate = json['creationDate'],
    _availableDate = json['availableDate'],
    _pageUrl = json['pageUrl'],
    _elementUrl = json['elementUrl'],
    _derivatives = json['derivatives'].map((json) => DerivativeModel.fromJson(json));

  Map<String, DerivativeModel> get derivatives => _derivatives;
  String get elementUrl => _elementUrl;
  String get pageUrl => _pageUrl;
  String get availableDate => _availableDate;
  String get creationDate => _creationDate;
  String get comment => _comment;
  String get name => _name;
  String get file => _file;
  int get hit => _hit;
  int get height => _height;
  int get width => _width;
  int get id => _id;
}