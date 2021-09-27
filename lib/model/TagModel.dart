class TagModel {
  int _id;
  String _name;
  String _urlName;
  String _lastModified;
  int _counter;
  String _url;

  TagModel(this._id, this._name, {
    String urlName,
    String lastModified,
    int counter,
    String url,
  }) {
    _urlName = urlName ?? '';
    _lastModified = lastModified ?? '';
    _counter = counter ?? 0;
    _url = url ?? '';
  }

  TagModel.fromJson(Map<String, dynamic> json) :
      _id = int.parse(json['id']),
      _name = json['name'],
      _urlName = json['url_name'] ?? '',
      _lastModified = json['lastmodified'] ?? '',
      _counter = json['counter'] ?? 0,
      _url = json['url'] ?? '';


  int compareTo(TagModel tag) {
    return _name.toLowerCase().compareTo(tag.name.toLowerCase());
  }


  String get url => _url;
  int get counter => _counter;
  String get lastModified => _lastModified;
  String get urlName => _urlName;
  String get name => _name;
  int get id => _id;
}