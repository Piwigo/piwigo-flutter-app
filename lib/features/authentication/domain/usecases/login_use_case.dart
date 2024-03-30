import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/authentication/data/repositories/authentication_repository.impl.dart';
import 'package:piwigo_ng/features/authentication/domain/repositories/authentication_repository.dart';

class LoginUseCase {
  const LoginUseCase();

  final AuthenticationRepository _repository = const AuthenticationRepositoryImpl();

  Future<Result<void>> execute(LoginParams params) async => await _repository.login(params);
}

class LoginParams {
  const LoginParams({
    required this.url,
    this.username,
    this.password,
  });

  final Uri url;
  final String? username;
  final String? password;

  bool get isGuest => (username?.isEmpty ?? true) && (password?.isEmpty ?? true);
}

enum UrlSchemeEnum {
  http,
  https;

  static UrlSchemeEnum fromJson(String json) {
    switch (json) {
      case 'http':
        return UrlSchemeEnum.http;
      case 'https':
        return UrlSchemeEnum.https;
      default:
        throw UnimplementedError();
    }
  }

  static String get domainSeparator => '://';
}

extension UrlSchemeExtension on UrlSchemeEnum {
  String toJson() {
    switch (this) {
      case UrlSchemeEnum.http:
        return 'http';
      case UrlSchemeEnum.https:
        return 'https';
    }
  }

  String get urlPrefix => '${toJson()}${UrlSchemeEnum.domainSeparator}';
}
