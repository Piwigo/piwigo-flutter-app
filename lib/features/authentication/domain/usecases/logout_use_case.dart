import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/authentication/data/repositories/authentication_repository.impl.dart';
import 'package:piwigo_ng/features/authentication/domain/repositories/authentication_repository.dart';

class LogOutUseCase {
  const LogOutUseCase();

  final AuthenticationRepository _repository = const AuthenticationRepositoryImpl();

  Future<Result<void>> execute() async => await _repository.logout();
}
