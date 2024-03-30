import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum UserStatusEnum {
  guest,
  webmaster,
  admin,
  user,
}

extension UserStatusExtension on UserStatusEnum {
  bool get isGuest => this == UserStatusEnum.guest;

  bool get isAdmin => <UserStatusEnum>[
        UserStatusEnum.admin,
        UserStatusEnum.webmaster,
      ].contains(this);
}
