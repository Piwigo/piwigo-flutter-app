class TagModel {
  int id;
  String name;
  String urlName;
  DateTime? lastModified;
  int counter;
  String url;

  TagModel({
    required this.id,
    required this.name,
    this.urlName = '',
    this.lastModified,
    this.counter = 0,
    this.url = '',
  });

  TagModel.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id'].toString()),
        name = json['name'],
        urlName = json['url_name'] ?? '',
        lastModified = DateTime.tryParse(json['lastmodified'] ?? ''),
        counter = json['counter'] ?? 0,
        url = json['url'] ?? '';

  int compareTo(TagModel tag) {
    return name.toLowerCase().compareTo(tag.name.toLowerCase());
  }

  @override
  operator ==(other) => other is TagModel && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}
