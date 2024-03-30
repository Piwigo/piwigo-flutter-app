import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/authentication/domain/usecases/auto_login_use_case.dart';
import 'package:piwigo_ng/features/authentication/domain/usecases/login_use_case.dart';

part 'login_bloc.freezed.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState.initial()) {
    on<_LoginUserEvent>(_onLoginUser);
    on<_LoginGuestEvent>(_onLoginGuest);
    on<_AutoLoginEvent>(_onAutoLogin);
  }

  final LoginUseCase _loginUseCase = const LoginUseCase();
  final AutoLoginUseCase _autoLoginUseCase = const AutoLoginUseCase();

  Future<void> _onLoginUser(
    _LoginUserEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginState.loading());

    Result<void> response = await _loginUseCase.execute(
      LoginParams(
        url: event.url,
        username: event.username,
        password: event.password,
      ),
    );

    response.when(
      failure: (Failure failure) => emit(LoginState.failure(failure)),
      success: (_) => emit(LoginState.success()),
    );
  }

  Future<void> _onLoginGuest(
    _LoginGuestEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginState.loading());

    Result<void> response = await _loginUseCase.execute(
      LoginParams(
        url: event.url,
      ),
    );

    response.when(
      failure: (Failure failure) => emit(LoginState.failure(failure)),
      success: (_) => emit(LoginState.success()),
    );
  }

  Future<void> _onAutoLogin(
    _AutoLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginState.loading());

    Result<void> response = await _autoLoginUseCase.execute();

    response.when(
      failure: (Failure failure) => emit(LoginState.failure(failure)),
      success: (_) => emit(LoginState.success()),
    );
  }
}
