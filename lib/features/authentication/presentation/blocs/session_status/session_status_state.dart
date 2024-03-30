part of 'session_status_bloc.dart';

@freezed
class SessionStatusState with _$SessionStatusState {
  factory SessionStatusState.initial() = _SessionStatusInitialState;

  factory SessionStatusState.loading([SessionStatusEntity? status]) = _SessionStatusLoadingState;

  factory SessionStatusState.failure(Failure failure) = _SessionStatusErrorState;

  factory SessionStatusState.loggedIn(SessionStatusEntity status) = _SessionStatusLoggedInState;

  factory SessionStatusState.loggedOut() = _SessionStatusLoggedOutState;

  const SessionStatusState._();

  bool get isLoading => this is _SessionStatusLoadingState;

  SessionStatusEntity? get currentStatus {
    if (this is _SessionStatusLoggedInState) {
      return (this as _SessionStatusLoggedInState).status;
    } else if (this is _SessionStatusLoadingState) {
      return (this as _SessionStatusLoadingState).status;
    }
    return null;
  }

  UserStatusEnum get userStatus => currentStatus?.status ?? UserStatusEnum.guest;
}
