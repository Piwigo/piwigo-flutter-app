part of 'session_status_bloc.dart';

@freezed
class SessionStatusEvent with _$SessionStatusEvent {
  const factory SessionStatusEvent.getStatus() = _GetSessionStatusEvent;

  const factory SessionStatusEvent.logout() = _LogOutEvent;
}
