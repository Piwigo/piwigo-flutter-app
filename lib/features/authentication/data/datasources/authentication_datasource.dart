import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/authentication/data/models/session_status_model.dart';
import 'package:piwigo_ng/features/authentication/domain/usecases/login_use_case.dart';

abstract class AuthenticationDatasource {
  const AuthenticationDatasource();

  Future<Result<void>> login(LoginParams params);

  Future<Result<void>> autoLogin();

  Future<Result<void>> logout();

  Future<Result<SessionStatusModel>> getSessionStatus();
}
