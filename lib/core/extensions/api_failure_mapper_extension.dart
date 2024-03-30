import 'package:piwigo_ng/core/data/models/api_failure_model.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/utils/constants/api_errors.dart';

extension ApiFailureMapper on Failure {
  static Failure fromApiFailure(ApiFailureModel failure) {
    switch (failure.code) {
      case ApiErrors.invalidCredentialsCode:
        return const Failure.invalidCredentials();
      case ApiErrors.missingUsernameCode:
        return const Failure.invalidCredentials();
      default:
        return const Failure.unknown();
    }
  }
}
