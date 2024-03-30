import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/authentication/data/enums/user_status_enum.dart';
import 'package:piwigo_ng/features/authentication/domain/entities/session_status_entity.dart';
import 'package:piwigo_ng/features/authentication/domain/usecases/logout_use_case.dart';
import 'package:piwigo_ng/features/authentication/domain/usecases/session_status_use_case.dart';

part 'session_status_bloc.freezed.dart';

part 'session_status_event.dart';

part 'session_status_state.dart';

class SessionStatusBloc extends Bloc<SessionStatusEvent, SessionStatusState> {
  SessionStatusBloc() : super(SessionStatusState.initial()) {
    on<_GetSessionStatusEvent>(_onGetSessionStatus);
    on<_LogOutEvent>(_onLogout);
  }

  final SessionStatusUseCase _sessionStatusUseCase = const SessionStatusUseCase();
  final LogOutUseCase _logoutUseCase = const LogOutUseCase();

  Future<void> _onGetSessionStatus(
    _GetSessionStatusEvent event,
    Emitter<SessionStatusState> emit,
  ) async {
    emit(SessionStatusState.loading(state.currentStatus));

    Result<SessionStatusEntity> response = await _sessionStatusUseCase.execute();

    response.when(
      failure: (Failure failure) => emit(SessionStatusState.failure(failure)),
      success: (SessionStatusEntity status) => emit(SessionStatusState.loggedIn(status)),
    );
  }

  Future<void> _onLogout(
    _LogOutEvent event,
    Emitter<SessionStatusState> emit,
  ) async {
    emit(SessionStatusState.loading(state.currentStatus));

    Result<void> response = await _logoutUseCase.execute();

    response.when(
      failure: (Failure failure) => emit(SessionStatusState.failure(failure)),
      success: (_) => emit(SessionStatusState.loggedOut()),
    );
  }
}

mixin UserStatusMixin {
  UserStatusEnum getUserStatus(BuildContext context) => BlocProvider.of<SessionStatusBloc>(context).state.userStatus;

  bool isGuest(BuildContext context) => getUserStatus(context) == UserStatusEnum.guest;

  bool isAdmin(BuildContext context) => <UserStatusEnum>[UserStatusEnum.admin, UserStatusEnum.webmaster].contains(
        getUserStatus(context),
      );
}
