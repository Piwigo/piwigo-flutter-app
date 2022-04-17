class PageArguments {
  final bool isAdmin;
  final bool isFavorites;
  final String tag;
  final String category;
  final String title;
  final int index;
  final List<dynamic> images;
  PageArguments({
    this.isAdmin = false, this.isFavorites = false, this.tag, this.category,
    this.title, this.index, this.images
  });
}