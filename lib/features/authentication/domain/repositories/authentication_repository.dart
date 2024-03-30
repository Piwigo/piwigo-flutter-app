import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/authentication/domain/entities/session_status_entity.dart';
import 'package:piwigo_ng/features/authentication/domain/usecases/login_use_case.dart';

abstract class AuthenticationRepository {
  const AuthenticationRepository();

  Future<Result<void>> login(LoginParams params);

  Future<Result<void>> autoLogin();

  Future<Result<void>> logout();

  Future<Result<SessionStatusEntity>> getSessionStatus();
}
