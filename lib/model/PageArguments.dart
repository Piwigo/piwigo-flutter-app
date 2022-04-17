class PageArguments {
  final bool isAdmin;
  final String tag;
  final String category;
  final String title;
  final int index;
  final List<dynamic> images;
  PageArguments({
    this.isAdmin = false, this.tag, this.category, this.title, this.index, this.images
  });
}