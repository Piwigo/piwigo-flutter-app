class DerivativeModel {
  String _url;
  int _width;
  int _height;

  DerivativeModel(url, width, height) {
    _url = url ?? '';
    _width = width ?? 0;
    _height = height ?? 0;
  }

  DerivativeModel.fromJson(Map<String, dynamic> json) :
    _url = json['url'],
    _width = json['width'],
    _height = json['height'];


  int get height => _height;
  int get width => _width;
  String get url => _url;
}