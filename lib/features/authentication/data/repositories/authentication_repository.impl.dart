import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/authentication/data/datasources/authentication_datasource.dart';
import 'package:piwigo_ng/features/authentication/data/datasources/authentication_datasource.impl.dart';
import 'package:piwigo_ng/features/authentication/domain/entities/session_status_entity.dart';
import 'package:piwigo_ng/features/authentication/domain/repositories/authentication_repository.dart';
import 'package:piwigo_ng/features/authentication/domain/usecases/login_use_case.dart';

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  const AuthenticationRepositoryImpl();

  final AuthenticationDatasource _datasource = const AuthenticationDatasourceImpl();

  @override
  Future<Result<void>> login(LoginParams params) async => await _datasource.login(params);

  @override
  Future<Result<void>> autoLogin() async => await _datasource.autoLogin();

  @override
  Future<Result<void>> logout() async => await _datasource.logout();

  @override
  Future<Result<SessionStatusEntity>> getSessionStatus() async => await _datasource.getSessionStatus();
}
