

class CategoryModel {
  String _id;
  String _name;
  String _comment;
  List<CategoryModel> _children;
  int _nbImages;
  String _fullname;
  String _status;

  CategoryModel(this._id, this._name, {
    String comment,
    List<CategoryModel> children,
    int nbImages,
    String fullname,
    String status
  }) {
    _comment = comment ?? '';
    _children = children ?? [];
    _nbImages = nbImages ?? 0;
    _fullname = fullname ?? '';
    _status = status ?? 'public';
  }

  CategoryModel.fromJson(Map<String, dynamic> json) :
    _id = json['id'],
    _name = json['name'] ?? '',
    _comment = json['comment'] ?? '',
    _nbImages = json['nb_images'] == 'null' ? 0 : int.parse(json['nb_images'].toString()),
    _fullname = json['fullname'] ?? '',
    _status = json['status'] ?? 'public',
    _children = [];


  String get id => _id;
  String get name => _name;
  String get comment => _comment;
  List<CategoryModel> get children => _children;
  int get nbImages => _nbImages;
  String get fullname => _fullname;
  String get status => _status;


  @override
  String toString() {
    String str = _fullname;
    if(_children.length > 0) {
      _children.forEach((element) {str += "\n ${element.toString()}";});
    }
    return str;
  }
}