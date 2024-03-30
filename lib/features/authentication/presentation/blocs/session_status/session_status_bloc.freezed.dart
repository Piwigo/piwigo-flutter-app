// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_status_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$SessionStatusEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() getStatus,
    required TResult Function() logout,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? getStatus,
    TResult? Function()? logout,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? getStatus,
    TResult Function()? logout,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetSessionStatusEvent value) getStatus,
    required TResult Function(_LogOutEvent value) logout,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetSessionStatusEvent value)? getStatus,
    TResult? Function(_LogOutEvent value)? logout,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetSessionStatusEvent value)? getStatus,
    TResult Function(_LogOutEvent value)? logout,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionStatusEventCopyWith<$Res> {
  factory $SessionStatusEventCopyWith(SessionStatusEvent value, $Res Function(SessionStatusEvent) then) =
      _$SessionStatusEventCopyWithImpl<$Res, SessionStatusEvent>;
}

/// @nodoc
class _$SessionStatusEventCopyWithImpl<$Res, $Val extends SessionStatusEvent>
    implements $SessionStatusEventCopyWith<$Res> {
  _$SessionStatusEventCopyWithImpl(this._value, this._then);

// ignore: unused_field
  final $Val _value;
// ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$GetSessionStatusEventImplCopyWith<$Res> {
  factory _$$GetSessionStatusEventImplCopyWith(
          _$GetSessionStatusEventImpl value, $Res Function(_$GetSessionStatusEventImpl) then) =
      __$$GetSessionStatusEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GetSessionStatusEventImplCopyWithImpl<$Res>
    extends _$SessionStatusEventCopyWithImpl<$Res, _$GetSessionStatusEventImpl>
    implements _$$GetSessionStatusEventImplCopyWith<$Res> {
  __$$GetSessionStatusEventImplCopyWithImpl(
      _$GetSessionStatusEventImpl _value, $Res Function(_$GetSessionStatusEventImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$GetSessionStatusEventImpl implements _GetSessionStatusEvent {
  const _$GetSessionStatusEventImpl();

  @override
  String toString() {
    return 'SessionStatusEvent.getStatus()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$GetSessionStatusEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() getStatus,
    required TResult Function() logout,
  }) {
    return getStatus();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? getStatus,
    TResult? Function()? logout,
  }) {
    return getStatus?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? getStatus,
    TResult Function()? logout,
    required TResult orElse(),
  }) {
    if (getStatus != null) {
      return getStatus();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetSessionStatusEvent value) getStatus,
    required TResult Function(_LogOutEvent value) logout,
  }) {
    return getStatus(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetSessionStatusEvent value)? getStatus,
    TResult? Function(_LogOutEvent value)? logout,
  }) {
    return getStatus?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetSessionStatusEvent value)? getStatus,
    TResult Function(_LogOutEvent value)? logout,
    required TResult orElse(),
  }) {
    if (getStatus != null) {
      return getStatus(this);
    }
    return orElse();
  }
}

abstract class _GetSessionStatusEvent implements SessionStatusEvent {
  const factory _GetSessionStatusEvent() = _$GetSessionStatusEventImpl;
}

/// @nodoc
abstract class _$$LogOutEventImplCopyWith<$Res> {
  factory _$$LogOutEventImplCopyWith(_$LogOutEventImpl value, $Res Function(_$LogOutEventImpl) then) =
      __$$LogOutEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LogOutEventImplCopyWithImpl<$Res> extends _$SessionStatusEventCopyWithImpl<$Res, _$LogOutEventImpl>
    implements _$$LogOutEventImplCopyWith<$Res> {
  __$$LogOutEventImplCopyWithImpl(_$LogOutEventImpl _value, $Res Function(_$LogOutEventImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LogOutEventImpl implements _LogOutEvent {
  const _$LogOutEventImpl();

  @override
  String toString() {
    return 'SessionStatusEvent.logout()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$LogOutEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() getStatus,
    required TResult Function() logout,
  }) {
    return logout();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? getStatus,
    TResult? Function()? logout,
  }) {
    return logout?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? getStatus,
    TResult Function()? logout,
    required TResult orElse(),
  }) {
    if (logout != null) {
      return logout();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetSessionStatusEvent value) getStatus,
    required TResult Function(_LogOutEvent value) logout,
  }) {
    return logout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetSessionStatusEvent value)? getStatus,
    TResult? Function(_LogOutEvent value)? logout,
  }) {
    return logout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetSessionStatusEvent value)? getStatus,
    TResult Function(_LogOutEvent value)? logout,
    required TResult orElse(),
  }) {
    if (logout != null) {
      return logout(this);
    }
    return orElse();
  }
}

abstract class _LogOutEvent implements SessionStatusEvent {
  const factory _LogOutEvent() = _$LogOutEventImpl;
}

/// @nodoc
mixin _$SessionStatusState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(SessionStatusEntity? status) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(SessionStatusEntity status) loggedIn,
    required TResult Function() loggedOut,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(SessionStatusEntity? status)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(SessionStatusEntity status)? loggedIn,
    TResult? Function()? loggedOut,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(SessionStatusEntity? status)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(SessionStatusEntity status)? loggedIn,
    TResult Function()? loggedOut,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SessionStatusInitialState value) initial,
    required TResult Function(_SessionStatusLoadingState value) loading,
    required TResult Function(_SessionStatusErrorState value) failure,
    required TResult Function(_SessionStatusLoggedInState value) loggedIn,
    required TResult Function(_SessionStatusLoggedOutState value) loggedOut,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SessionStatusInitialState value)? initial,
    TResult? Function(_SessionStatusLoadingState value)? loading,
    TResult? Function(_SessionStatusErrorState value)? failure,
    TResult? Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult? Function(_SessionStatusLoggedOutState value)? loggedOut,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SessionStatusInitialState value)? initial,
    TResult Function(_SessionStatusLoadingState value)? loading,
    TResult Function(_SessionStatusErrorState value)? failure,
    TResult Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult Function(_SessionStatusLoggedOutState value)? loggedOut,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionStatusStateCopyWith<$Res> {
  factory $SessionStatusStateCopyWith(SessionStatusState value, $Res Function(SessionStatusState) then) =
      _$SessionStatusStateCopyWithImpl<$Res, SessionStatusState>;
}

/// @nodoc
class _$SessionStatusStateCopyWithImpl<$Res, $Val extends SessionStatusState>
    implements $SessionStatusStateCopyWith<$Res> {
  _$SessionStatusStateCopyWithImpl(this._value, this._then);

// ignore: unused_field
  final $Val _value;
// ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SessionStatusInitialStateImplCopyWith<$Res> {
  factory _$$SessionStatusInitialStateImplCopyWith(
          _$SessionStatusInitialStateImpl value, $Res Function(_$SessionStatusInitialStateImpl) then) =
      __$$SessionStatusInitialStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SessionStatusInitialStateImplCopyWithImpl<$Res>
    extends _$SessionStatusStateCopyWithImpl<$Res, _$SessionStatusInitialStateImpl>
    implements _$$SessionStatusInitialStateImplCopyWith<$Res> {
  __$$SessionStatusInitialStateImplCopyWithImpl(
      _$SessionStatusInitialStateImpl _value, $Res Function(_$SessionStatusInitialStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SessionStatusInitialStateImpl extends _SessionStatusInitialState {
  _$SessionStatusInitialStateImpl() : super._();

  @override
  String toString() {
    return 'SessionStatusState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$SessionStatusInitialStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(SessionStatusEntity? status) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(SessionStatusEntity status) loggedIn,
    required TResult Function() loggedOut,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(SessionStatusEntity? status)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(SessionStatusEntity status)? loggedIn,
    TResult? Function()? loggedOut,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(SessionStatusEntity? status)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(SessionStatusEntity status)? loggedIn,
    TResult Function()? loggedOut,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SessionStatusInitialState value) initial,
    required TResult Function(_SessionStatusLoadingState value) loading,
    required TResult Function(_SessionStatusErrorState value) failure,
    required TResult Function(_SessionStatusLoggedInState value) loggedIn,
    required TResult Function(_SessionStatusLoggedOutState value) loggedOut,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SessionStatusInitialState value)? initial,
    TResult? Function(_SessionStatusLoadingState value)? loading,
    TResult? Function(_SessionStatusErrorState value)? failure,
    TResult? Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult? Function(_SessionStatusLoggedOutState value)? loggedOut,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SessionStatusInitialState value)? initial,
    TResult Function(_SessionStatusLoadingState value)? loading,
    TResult Function(_SessionStatusErrorState value)? failure,
    TResult Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult Function(_SessionStatusLoggedOutState value)? loggedOut,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _SessionStatusInitialState extends SessionStatusState {
  factory _SessionStatusInitialState() = _$SessionStatusInitialStateImpl;
  _SessionStatusInitialState._() : super._();
}

/// @nodoc
abstract class _$$SessionStatusLoadingStateImplCopyWith<$Res> {
  factory _$$SessionStatusLoadingStateImplCopyWith(
          _$SessionStatusLoadingStateImpl value, $Res Function(_$SessionStatusLoadingStateImpl) then) =
      __$$SessionStatusLoadingStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SessionStatusEntity? status});
}

/// @nodoc
class __$$SessionStatusLoadingStateImplCopyWithImpl<$Res>
    extends _$SessionStatusStateCopyWithImpl<$Res, _$SessionStatusLoadingStateImpl>
    implements _$$SessionStatusLoadingStateImplCopyWith<$Res> {
  __$$SessionStatusLoadingStateImplCopyWithImpl(
      _$SessionStatusLoadingStateImpl _value, $Res Function(_$SessionStatusLoadingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
  }) {
    return _then(_$SessionStatusLoadingStateImpl(
      freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatusEntity?,
    ));
  }
}

/// @nodoc

class _$SessionStatusLoadingStateImpl extends _SessionStatusLoadingState {
  _$SessionStatusLoadingStateImpl([this.status]) : super._();

  @override
  final SessionStatusEntity? status;

  @override
  String toString() {
    return 'SessionStatusState.loading(status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionStatusLoadingStateImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionStatusLoadingStateImplCopyWith<_$SessionStatusLoadingStateImpl> get copyWith =>
      __$$SessionStatusLoadingStateImplCopyWithImpl<_$SessionStatusLoadingStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(SessionStatusEntity? status) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(SessionStatusEntity status) loggedIn,
    required TResult Function() loggedOut,
  }) {
    return loading(status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(SessionStatusEntity? status)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(SessionStatusEntity status)? loggedIn,
    TResult? Function()? loggedOut,
  }) {
    return loading?.call(status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(SessionStatusEntity? status)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(SessionStatusEntity status)? loggedIn,
    TResult Function()? loggedOut,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SessionStatusInitialState value) initial,
    required TResult Function(_SessionStatusLoadingState value) loading,
    required TResult Function(_SessionStatusErrorState value) failure,
    required TResult Function(_SessionStatusLoggedInState value) loggedIn,
    required TResult Function(_SessionStatusLoggedOutState value) loggedOut,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SessionStatusInitialState value)? initial,
    TResult? Function(_SessionStatusLoadingState value)? loading,
    TResult? Function(_SessionStatusErrorState value)? failure,
    TResult? Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult? Function(_SessionStatusLoggedOutState value)? loggedOut,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SessionStatusInitialState value)? initial,
    TResult Function(_SessionStatusLoadingState value)? loading,
    TResult Function(_SessionStatusErrorState value)? failure,
    TResult Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult Function(_SessionStatusLoggedOutState value)? loggedOut,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _SessionStatusLoadingState extends SessionStatusState {
  factory _SessionStatusLoadingState([final SessionStatusEntity? status]) = _$SessionStatusLoadingStateImpl;
  _SessionStatusLoadingState._() : super._();

  SessionStatusEntity? get status;
  @JsonKey(ignore: true)
  _$$SessionStatusLoadingStateImplCopyWith<_$SessionStatusLoadingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionStatusErrorStateImplCopyWith<$Res> {
  factory _$$SessionStatusErrorStateImplCopyWith(
          _$SessionStatusErrorStateImpl value, $Res Function(_$SessionStatusErrorStateImpl) then) =
      __$$SessionStatusErrorStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});

  $FailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$SessionStatusErrorStateImplCopyWithImpl<$Res>
    extends _$SessionStatusStateCopyWithImpl<$Res, _$SessionStatusErrorStateImpl>
    implements _$$SessionStatusErrorStateImplCopyWith<$Res> {
  __$$SessionStatusErrorStateImplCopyWithImpl(
      _$SessionStatusErrorStateImpl _value, $Res Function(_$SessionStatusErrorStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$SessionStatusErrorStateImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $FailureCopyWith<$Res> get failure {
    return $FailureCopyWith<$Res>(_value.failure, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }
}

/// @nodoc

class _$SessionStatusErrorStateImpl extends _SessionStatusErrorState {
  _$SessionStatusErrorStateImpl(this.failure) : super._();

  @override
  final Failure failure;

  @override
  String toString() {
    return 'SessionStatusState.failure(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionStatusErrorStateImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionStatusErrorStateImplCopyWith<_$SessionStatusErrorStateImpl> get copyWith =>
      __$$SessionStatusErrorStateImplCopyWithImpl<_$SessionStatusErrorStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(SessionStatusEntity? status) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(SessionStatusEntity status) loggedIn,
    required TResult Function() loggedOut,
  }) {
    return failure(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(SessionStatusEntity? status)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(SessionStatusEntity status)? loggedIn,
    TResult? Function()? loggedOut,
  }) {
    return failure?.call(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(SessionStatusEntity? status)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(SessionStatusEntity status)? loggedIn,
    TResult Function()? loggedOut,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this.failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SessionStatusInitialState value) initial,
    required TResult Function(_SessionStatusLoadingState value) loading,
    required TResult Function(_SessionStatusErrorState value) failure,
    required TResult Function(_SessionStatusLoggedInState value) loggedIn,
    required TResult Function(_SessionStatusLoggedOutState value) loggedOut,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SessionStatusInitialState value)? initial,
    TResult? Function(_SessionStatusLoadingState value)? loading,
    TResult? Function(_SessionStatusErrorState value)? failure,
    TResult? Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult? Function(_SessionStatusLoggedOutState value)? loggedOut,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SessionStatusInitialState value)? initial,
    TResult Function(_SessionStatusLoadingState value)? loading,
    TResult Function(_SessionStatusErrorState value)? failure,
    TResult Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult Function(_SessionStatusLoggedOutState value)? loggedOut,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _SessionStatusErrorState extends SessionStatusState {
  factory _SessionStatusErrorState(final Failure failure) = _$SessionStatusErrorStateImpl;
  _SessionStatusErrorState._() : super._();

  Failure get failure;
  @JsonKey(ignore: true)
  _$$SessionStatusErrorStateImplCopyWith<_$SessionStatusErrorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionStatusLoggedInStateImplCopyWith<$Res> {
  factory _$$SessionStatusLoggedInStateImplCopyWith(
          _$SessionStatusLoggedInStateImpl value, $Res Function(_$SessionStatusLoggedInStateImpl) then) =
      __$$SessionStatusLoggedInStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SessionStatusEntity status});
}

/// @nodoc
class __$$SessionStatusLoggedInStateImplCopyWithImpl<$Res>
    extends _$SessionStatusStateCopyWithImpl<$Res, _$SessionStatusLoggedInStateImpl>
    implements _$$SessionStatusLoggedInStateImplCopyWith<$Res> {
  __$$SessionStatusLoggedInStateImplCopyWithImpl(
      _$SessionStatusLoggedInStateImpl _value, $Res Function(_$SessionStatusLoggedInStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_$SessionStatusLoggedInStateImpl(
      null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatusEntity,
    ));
  }
}

/// @nodoc

class _$SessionStatusLoggedInStateImpl extends _SessionStatusLoggedInState {
  _$SessionStatusLoggedInStateImpl(this.status) : super._();

  @override
  final SessionStatusEntity status;

  @override
  String toString() {
    return 'SessionStatusState.loggedIn(status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionStatusLoggedInStateImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionStatusLoggedInStateImplCopyWith<_$SessionStatusLoggedInStateImpl> get copyWith =>
      __$$SessionStatusLoggedInStateImplCopyWithImpl<_$SessionStatusLoggedInStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(SessionStatusEntity? status) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(SessionStatusEntity status) loggedIn,
    required TResult Function() loggedOut,
  }) {
    return loggedIn(status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(SessionStatusEntity? status)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(SessionStatusEntity status)? loggedIn,
    TResult? Function()? loggedOut,
  }) {
    return loggedIn?.call(status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(SessionStatusEntity? status)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(SessionStatusEntity status)? loggedIn,
    TResult Function()? loggedOut,
    required TResult orElse(),
  }) {
    if (loggedIn != null) {
      return loggedIn(status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SessionStatusInitialState value) initial,
    required TResult Function(_SessionStatusLoadingState value) loading,
    required TResult Function(_SessionStatusErrorState value) failure,
    required TResult Function(_SessionStatusLoggedInState value) loggedIn,
    required TResult Function(_SessionStatusLoggedOutState value) loggedOut,
  }) {
    return loggedIn(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SessionStatusInitialState value)? initial,
    TResult? Function(_SessionStatusLoadingState value)? loading,
    TResult? Function(_SessionStatusErrorState value)? failure,
    TResult? Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult? Function(_SessionStatusLoggedOutState value)? loggedOut,
  }) {
    return loggedIn?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SessionStatusInitialState value)? initial,
    TResult Function(_SessionStatusLoadingState value)? loading,
    TResult Function(_SessionStatusErrorState value)? failure,
    TResult Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult Function(_SessionStatusLoggedOutState value)? loggedOut,
    required TResult orElse(),
  }) {
    if (loggedIn != null) {
      return loggedIn(this);
    }
    return orElse();
  }
}

abstract class _SessionStatusLoggedInState extends SessionStatusState {
  factory _SessionStatusLoggedInState(final SessionStatusEntity status) = _$SessionStatusLoggedInStateImpl;
  _SessionStatusLoggedInState._() : super._();

  SessionStatusEntity get status;
  @JsonKey(ignore: true)
  _$$SessionStatusLoggedInStateImplCopyWith<_$SessionStatusLoggedInStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionStatusLoggedOutStateImplCopyWith<$Res> {
  factory _$$SessionStatusLoggedOutStateImplCopyWith(
          _$SessionStatusLoggedOutStateImpl value, $Res Function(_$SessionStatusLoggedOutStateImpl) then) =
      __$$SessionStatusLoggedOutStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SessionStatusLoggedOutStateImplCopyWithImpl<$Res>
    extends _$SessionStatusStateCopyWithImpl<$Res, _$SessionStatusLoggedOutStateImpl>
    implements _$$SessionStatusLoggedOutStateImplCopyWith<$Res> {
  __$$SessionStatusLoggedOutStateImplCopyWithImpl(
      _$SessionStatusLoggedOutStateImpl _value, $Res Function(_$SessionStatusLoggedOutStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SessionStatusLoggedOutStateImpl extends _SessionStatusLoggedOutState {
  _$SessionStatusLoggedOutStateImpl() : super._();

  @override
  String toString() {
    return 'SessionStatusState.loggedOut()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$SessionStatusLoggedOutStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(SessionStatusEntity? status) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(SessionStatusEntity status) loggedIn,
    required TResult Function() loggedOut,
  }) {
    return loggedOut();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(SessionStatusEntity? status)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(SessionStatusEntity status)? loggedIn,
    TResult? Function()? loggedOut,
  }) {
    return loggedOut?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(SessionStatusEntity? status)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(SessionStatusEntity status)? loggedIn,
    TResult Function()? loggedOut,
    required TResult orElse(),
  }) {
    if (loggedOut != null) {
      return loggedOut();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SessionStatusInitialState value) initial,
    required TResult Function(_SessionStatusLoadingState value) loading,
    required TResult Function(_SessionStatusErrorState value) failure,
    required TResult Function(_SessionStatusLoggedInState value) loggedIn,
    required TResult Function(_SessionStatusLoggedOutState value) loggedOut,
  }) {
    return loggedOut(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SessionStatusInitialState value)? initial,
    TResult? Function(_SessionStatusLoadingState value)? loading,
    TResult? Function(_SessionStatusErrorState value)? failure,
    TResult? Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult? Function(_SessionStatusLoggedOutState value)? loggedOut,
  }) {
    return loggedOut?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SessionStatusInitialState value)? initial,
    TResult Function(_SessionStatusLoadingState value)? loading,
    TResult Function(_SessionStatusErrorState value)? failure,
    TResult Function(_SessionStatusLoggedInState value)? loggedIn,
    TResult Function(_SessionStatusLoggedOutState value)? loggedOut,
    required TResult orElse(),
  }) {
    if (loggedOut != null) {
      return loggedOut(this);
    }
    return orElse();
  }
}

abstract class _SessionStatusLoggedOutState extends SessionStatusState {
  factory _SessionStatusLoggedOutState() = _$SessionStatusLoggedOutStateImpl;
  _SessionStatusLoggedOutState._() : super._();
}
