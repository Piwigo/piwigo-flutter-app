class AlbumPermissionModel {
  final int albumId;
  final List<int> users;
  final List<int> indirectUsers;
  final List<int> groups;

  const AlbumPermissionModel({
    required this.albumId,
    this.users = const [],
    this.indirectUsers = const [],
    this.groups = const [],
  });

  AlbumPermissionModel.fromJson(Map<String, dynamic> json)
      : albumId = json['id'],
        users = json['users']?.cast<int>() ?? [],
        indirectUsers = json['users_indirect']?.cast<int>() ?? [],
        groups = json['groups']?.cast<int>() ?? [];

  Map<String, dynamic> toJson() => {
        'id': albumId,
        'users': users,
        'users_indirect': indirectUsers,
        'groups': groups,
      };
}
