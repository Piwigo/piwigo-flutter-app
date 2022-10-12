class TagModel {
  int id;
  String name;
  String urlName;
  String lastModified;
  int counter;
  String url;

  TagModel(
    this.id,
    this.name, {
    this.urlName = '',
    this.lastModified = '',
    this.counter = 0,
    this.url = '',
  });

  TagModel.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        name = json['name'],
        urlName = json['url_name'] ?? '',
        lastModified = json['lastmodified'] ?? '',
        counter = json['counter'] ?? 0,
        url = json['url'] ?? '';

  int compareTo(TagModel tag) {
    return name.toLowerCase().compareTo(tag.name.toLowerCase());
  }
}
