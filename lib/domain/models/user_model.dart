class UserModel {
  final int id;
  final String name;
  final String? email;
  final String status;
  final int level;
  final List<int> groups;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.status = 'guest',
    this.level = 0,
    this.groups = const [],
  });

  UserModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['username'],
        email = json['email'],
        status = json['status'],
        level = int.parse(json['level']),
        groups = json['groups'].cast<int>();

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': name,
        'email': email,
        'status': status,
        'level': level,
        'groups': groups,
      };
}
