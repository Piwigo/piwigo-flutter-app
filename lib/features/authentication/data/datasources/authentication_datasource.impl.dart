import 'package:dio/dio.dart';
import 'package:piwigo_ng/core/data/datasources/local/preferences_datasource.dart';
import 'package:piwigo_ng/core/data/datasources/local/secure_storage_datasource.dart';
import 'package:piwigo_ng/core/data/datasources/remote/remote_datasource.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/utils/constants/api_constants.dart';
import 'package:piwigo_ng/core/utils/constants/local_key_constants.dart';
import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/authentication/data/datasources/authentication_datasource.dart';
import 'package:piwigo_ng/features/authentication/data/models/session_status_model.dart';
import 'package:piwigo_ng/features/authentication/domain/usecases/login_use_case.dart';

class AuthenticationDatasourceImpl extends AuthenticationDatasource {
  const AuthenticationDatasourceImpl();

  final RemoteDatasource _remote = const RemoteDatasource();
  final PreferencesDatasource _preferences = const PreferencesDatasource();
  final SecureStorageDatasource _secureStorage = const SecureStorageDatasource();

  @override
  Future<Result<void>> login(LoginParams params) async {
    _preferences.instance.setString(LocalKeyConstants.serverUrlKey, params.url.toString());

    if (params.isGuest) return const Result<void>.success(null);

    // Save credentials
    await _secureStorage.instance.write(key: LocalKeyConstants.usernameKey, value: params.username);
    await _secureStorage.instance.write(key: LocalKeyConstants.passwordKey, value: params.password);

    Map<String, String> data = <String, String>{
      'username': params.username ?? '',
      'password': params.password ?? '',
    };

    Result<bool> response = await _remote.post<bool>(
      method: ApiConstants.loginMethod,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return response.when(
      failure: (Failure failure) => Result<void>.failure(failure),
      success: (bool success) {
        if (success) {
          return const Result<void>.success(null);
        }
        return const Result<void>.failure(Failure.unknown());
      },
    );
  }

  @override
  Future<Result<void>> autoLogin() async {
    String? baseUrl = _preferences.instance.getString(LocalKeyConstants.serverUrlKey);
    String? username = await _secureStorage.instance.read(key: LocalKeyConstants.usernameKey);
    String? password = await _secureStorage.instance.read(key: LocalKeyConstants.passwordKey);

    // No server url registered
    if (baseUrl == null) return const Result<void>.failure(Failure.unknown());

    // User is guest
    if (username == null && password == null) return const Result<void>.success(null);

    Result<void> response = await login(
      LoginParams(
        url: Uri.parse(baseUrl),
        username: username,
        password: password,
      ),
    );

    return response.when(
      failure: (Failure failure) => Result<void>.failure(failure),
      success: (_) => const Result<void>.success(null),
    );
  }

  @override
  Future<Result<void>> logout() async {
    Result<bool> response = await _remote.get<bool>(
      method: ApiConstants.logoutMethod,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return response.when(
      failure: (Failure failure) => Result<void>.failure(failure),
      success: (bool success) async {
        if (success) {
          _preferences.instance.remove(LocalKeyConstants.serverUrlKey);
          await _secureStorage.instance.delete(key: LocalKeyConstants.usernameKey);
          await _secureStorage.instance.delete(key: LocalKeyConstants.passwordKey);
          return const Result<void>.success(null);
        }
        return const Result<void>.failure(Failure.unknown());
      },
    );
  }

  @override
  Future<Result<SessionStatusModel>> getSessionStatus() async {
    Result<Map<String, dynamic>> response = await _remote.get<Map<String, dynamic>>(
      method: ApiConstants.getStatusMethod,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return response.when(
      failure: (Failure failure) => Result<SessionStatusModel>.failure(failure),
      success: (Map<String, dynamic> data) => Result<SessionStatusModel>.success(SessionStatusModel.fromJson(data)),
    );
  }
}
