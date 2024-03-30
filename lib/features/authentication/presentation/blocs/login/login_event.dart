part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.loginUser({
    required Uri url,
    required String username,
    required String password,
  }) = _LoginUserEvent;

  const factory LoginEvent.loginGuest({
    required Uri url,
  }) = _LoginGuestEvent;

  const factory LoginEvent.autoLogin() = _AutoLoginEvent;
}
