

class CategoryModel {
  String id;
  String name;
  String comment;
  List<CategoryModel> children;
  String nbImages;
  String fullname;
  String status;

  CategoryModel(this.id, this.name, {this.comment = "", this.nbImages = "0", this.fullname = "",
    this.status = "public"}) {
    children = [];
  }

  @override
  String toString() {
    String str;
    str = fullname;
    if(children.length > 0) {
      children.forEach((element) {str += "\n ${element.toString()}";});
    }
    return str;
  }
}