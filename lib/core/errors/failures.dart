import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const Failure._();

  const factory Failure.unknown() = _UnknownFailure;

  const factory Failure.connectivity() = ConnectivityFailure;

  const factory Failure.dio(DioError error) = DioFailure;

  //region Authentication
  const factory Failure.invalidCredentials() = InvalidCredentialsFailure;

  // const factory Failure.loginError() = LoginErrorFailure;
  //endregion

  String getMessage(BuildContext context) {
    switch (runtimeType) {
      case DioFailure:
        return (this as DioError).message;
      case _UnknownFailure:
      default:
        return context.localizations.serverUnknownError_message;
    }
  }
}
