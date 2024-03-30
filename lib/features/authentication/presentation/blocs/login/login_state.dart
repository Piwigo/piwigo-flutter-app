part of 'login_bloc.dart';

@freezed
class LoginState with _$LoginState {
  factory LoginState.initial() = _LoginInitialState;

  factory LoginState.loading() = _LoginLoadingState;

  factory LoginState.failure(Failure failure) = _LoginErrorState;

  factory LoginState.success() = _LoginSuccessState;

  const LoginState._();

  bool get isLoading => this is _LoginLoadingState;
}
