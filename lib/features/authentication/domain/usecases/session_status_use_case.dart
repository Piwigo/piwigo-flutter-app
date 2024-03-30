import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/authentication/data/repositories/authentication_repository.impl.dart';
import 'package:piwigo_ng/features/authentication/domain/entities/session_status_entity.dart';
import 'package:piwigo_ng/features/authentication/domain/repositories/authentication_repository.dart';

class SessionStatusUseCase {
  const SessionStatusUseCase();

  final AuthenticationRepository _repository = const AuthenticationRepositoryImpl();

  Future<Result<SessionStatusEntity>> execute() async => await _repository.getSessionStatus();
}
