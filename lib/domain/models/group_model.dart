class GroupModel {
  final int id;
  final String name;
  final bool isDefault;
  final DateTime? lastModified;
  final int nbUsers;

  GroupModel({
    required this.id,
    required this.name,
    this.isDefault = false,
    this.lastModified,
    this.nbUsers = 0,
  });

  GroupModel.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        name = json['name'],
        isDefault = json['is_default'] == 'true',
        lastModified = DateTime.parse(json['lastmodified']),
        nbUsers = int.tryParse(json['nb_users']) ?? 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_default': isDefault,
      };

  int compareTo(GroupModel group) {
    return name.toLowerCase().compareTo(group.name.toLowerCase());
  }

  @override
  operator ==(other) =>
      other is GroupModel && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}
