// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$LoginEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Uri url, String username, String password) loginUser,
    required TResult Function(Uri url) loginGuest,
    required TResult Function() autoLogin,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Uri url, String username, String password)? loginUser,
    TResult? Function(Uri url)? loginGuest,
    TResult? Function()? autoLogin,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Uri url, String username, String password)? loginUser,
    TResult Function(Uri url)? loginGuest,
    TResult Function()? autoLogin,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoginUserEvent value) loginUser,
    required TResult Function(_LoginGuestEvent value) loginGuest,
    required TResult Function(_AutoLoginEvent value) autoLogin,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoginUserEvent value)? loginUser,
    TResult? Function(_LoginGuestEvent value)? loginGuest,
    TResult? Function(_AutoLoginEvent value)? autoLogin,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoginUserEvent value)? loginUser,
    TResult Function(_LoginGuestEvent value)? loginGuest,
    TResult Function(_AutoLoginEvent value)? autoLogin,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginEventCopyWith<$Res> {
  factory $LoginEventCopyWith(LoginEvent value, $Res Function(LoginEvent) then) =
      _$LoginEventCopyWithImpl<$Res, LoginEvent>;
}

/// @nodoc
class _$LoginEventCopyWithImpl<$Res, $Val extends LoginEvent> implements $LoginEventCopyWith<$Res> {
  _$LoginEventCopyWithImpl(this._value, this._then);

// ignore: unused_field
  final $Val _value;
// ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LoginUserEventImplCopyWith<$Res> {
  factory _$$LoginUserEventImplCopyWith(_$LoginUserEventImpl value, $Res Function(_$LoginUserEventImpl) then) =
      __$$LoginUserEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Uri url, String username, String password});
}

/// @nodoc
class __$$LoginUserEventImplCopyWithImpl<$Res> extends _$LoginEventCopyWithImpl<$Res, _$LoginUserEventImpl>
    implements _$$LoginUserEventImplCopyWith<$Res> {
  __$$LoginUserEventImplCopyWithImpl(_$LoginUserEventImpl _value, $Res Function(_$LoginUserEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? username = null,
    Object? password = null,
  }) {
    return _then(_$LoginUserEventImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as Uri,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LoginUserEventImpl implements _LoginUserEvent {
  const _$LoginUserEventImpl({required this.url, required this.username, required this.password});

  @override
  final Uri url;
  @override
  final String username;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginEvent.loginUser(url: $url, username: $username, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginUserEventImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.username, username) || other.username == username) &&
            (identical(other.password, password) || other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, url, username, password);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginUserEventImplCopyWith<_$LoginUserEventImpl> get copyWith =>
      __$$LoginUserEventImplCopyWithImpl<_$LoginUserEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Uri url, String username, String password) loginUser,
    required TResult Function(Uri url) loginGuest,
    required TResult Function() autoLogin,
  }) {
    return loginUser(url, username, password);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Uri url, String username, String password)? loginUser,
    TResult? Function(Uri url)? loginGuest,
    TResult? Function()? autoLogin,
  }) {
    return loginUser?.call(url, username, password);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Uri url, String username, String password)? loginUser,
    TResult Function(Uri url)? loginGuest,
    TResult Function()? autoLogin,
    required TResult orElse(),
  }) {
    if (loginUser != null) {
      return loginUser(url, username, password);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoginUserEvent value) loginUser,
    required TResult Function(_LoginGuestEvent value) loginGuest,
    required TResult Function(_AutoLoginEvent value) autoLogin,
  }) {
    return loginUser(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoginUserEvent value)? loginUser,
    TResult? Function(_LoginGuestEvent value)? loginGuest,
    TResult? Function(_AutoLoginEvent value)? autoLogin,
  }) {
    return loginUser?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoginUserEvent value)? loginUser,
    TResult Function(_LoginGuestEvent value)? loginGuest,
    TResult Function(_AutoLoginEvent value)? autoLogin,
    required TResult orElse(),
  }) {
    if (loginUser != null) {
      return loginUser(this);
    }
    return orElse();
  }
}

abstract class _LoginUserEvent implements LoginEvent {
  const factory _LoginUserEvent(
      {required final Uri url, required final String username, required final String password}) = _$LoginUserEventImpl;

  Uri get url;
  String get username;
  String get password;
  @JsonKey(ignore: true)
  _$$LoginUserEventImplCopyWith<_$LoginUserEventImpl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoginGuestEventImplCopyWith<$Res> {
  factory _$$LoginGuestEventImplCopyWith(_$LoginGuestEventImpl value, $Res Function(_$LoginGuestEventImpl) then) =
      __$$LoginGuestEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Uri url});
}

/// @nodoc
class __$$LoginGuestEventImplCopyWithImpl<$Res> extends _$LoginEventCopyWithImpl<$Res, _$LoginGuestEventImpl>
    implements _$$LoginGuestEventImplCopyWith<$Res> {
  __$$LoginGuestEventImplCopyWithImpl(_$LoginGuestEventImpl _value, $Res Function(_$LoginGuestEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
  }) {
    return _then(_$LoginGuestEventImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as Uri,
    ));
  }
}

/// @nodoc

class _$LoginGuestEventImpl implements _LoginGuestEvent {
  const _$LoginGuestEventImpl({required this.url});

  @override
  final Uri url;

  @override
  String toString() {
    return 'LoginEvent.loginGuest(url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginGuestEventImpl &&
            (identical(other.url, url) || other.url == url));
  }

  @override
  int get hashCode => Object.hash(runtimeType, url);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginGuestEventImplCopyWith<_$LoginGuestEventImpl> get copyWith =>
      __$$LoginGuestEventImplCopyWithImpl<_$LoginGuestEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Uri url, String username, String password) loginUser,
    required TResult Function(Uri url) loginGuest,
    required TResult Function() autoLogin,
  }) {
    return loginGuest(url);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Uri url, String username, String password)? loginUser,
    TResult? Function(Uri url)? loginGuest,
    TResult? Function()? autoLogin,
  }) {
    return loginGuest?.call(url);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Uri url, String username, String password)? loginUser,
    TResult Function(Uri url)? loginGuest,
    TResult Function()? autoLogin,
    required TResult orElse(),
  }) {
    if (loginGuest != null) {
      return loginGuest(url);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoginUserEvent value) loginUser,
    required TResult Function(_LoginGuestEvent value) loginGuest,
    required TResult Function(_AutoLoginEvent value) autoLogin,
  }) {
    return loginGuest(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoginUserEvent value)? loginUser,
    TResult? Function(_LoginGuestEvent value)? loginGuest,
    TResult? Function(_AutoLoginEvent value)? autoLogin,
  }) {
    return loginGuest?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoginUserEvent value)? loginUser,
    TResult Function(_LoginGuestEvent value)? loginGuest,
    TResult Function(_AutoLoginEvent value)? autoLogin,
    required TResult orElse(),
  }) {
    if (loginGuest != null) {
      return loginGuest(this);
    }
    return orElse();
  }
}

abstract class _LoginGuestEvent implements LoginEvent {
  const factory _LoginGuestEvent({required final Uri url}) = _$LoginGuestEventImpl;

  Uri get url;
  @JsonKey(ignore: true)
  _$$LoginGuestEventImplCopyWith<_$LoginGuestEventImpl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AutoLoginEventImplCopyWith<$Res> {
  factory _$$AutoLoginEventImplCopyWith(_$AutoLoginEventImpl value, $Res Function(_$AutoLoginEventImpl) then) =
      __$$AutoLoginEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AutoLoginEventImplCopyWithImpl<$Res> extends _$LoginEventCopyWithImpl<$Res, _$AutoLoginEventImpl>
    implements _$$AutoLoginEventImplCopyWith<$Res> {
  __$$AutoLoginEventImplCopyWithImpl(_$AutoLoginEventImpl _value, $Res Function(_$AutoLoginEventImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AutoLoginEventImpl implements _AutoLoginEvent {
  const _$AutoLoginEventImpl();

  @override
  String toString() {
    return 'LoginEvent.autoLogin()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$AutoLoginEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Uri url, String username, String password) loginUser,
    required TResult Function(Uri url) loginGuest,
    required TResult Function() autoLogin,
  }) {
    return autoLogin();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Uri url, String username, String password)? loginUser,
    TResult? Function(Uri url)? loginGuest,
    TResult? Function()? autoLogin,
  }) {
    return autoLogin?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Uri url, String username, String password)? loginUser,
    TResult Function(Uri url)? loginGuest,
    TResult Function()? autoLogin,
    required TResult orElse(),
  }) {
    if (autoLogin != null) {
      return autoLogin();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoginUserEvent value) loginUser,
    required TResult Function(_LoginGuestEvent value) loginGuest,
    required TResult Function(_AutoLoginEvent value) autoLogin,
  }) {
    return autoLogin(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoginUserEvent value)? loginUser,
    TResult? Function(_LoginGuestEvent value)? loginGuest,
    TResult? Function(_AutoLoginEvent value)? autoLogin,
  }) {
    return autoLogin?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoginUserEvent value)? loginUser,
    TResult Function(_LoginGuestEvent value)? loginGuest,
    TResult Function(_AutoLoginEvent value)? autoLogin,
    required TResult orElse(),
  }) {
    if (autoLogin != null) {
      return autoLogin(this);
    }
    return orElse();
  }
}

abstract class _AutoLoginEvent implements LoginEvent {
  const factory _AutoLoginEvent() = _$AutoLoginEventImpl;
}

/// @nodoc
mixin _$LoginState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Failure failure) failure,
    required TResult Function() success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function()? success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Failure failure)? failure,
    TResult Function()? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoginInitialState value) initial,
    required TResult Function(_LoginLoadingState value) loading,
    required TResult Function(_LoginErrorState value) failure,
    required TResult Function(_LoginSuccessState value) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoginInitialState value)? initial,
    TResult? Function(_LoginLoadingState value)? loading,
    TResult? Function(_LoginErrorState value)? failure,
    TResult? Function(_LoginSuccessState value)? success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoginInitialState value)? initial,
    TResult Function(_LoginLoadingState value)? loading,
    TResult Function(_LoginErrorState value)? failure,
    TResult Function(_LoginSuccessState value)? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginStateCopyWith<$Res> {
  factory $LoginStateCopyWith(LoginState value, $Res Function(LoginState) then) =
      _$LoginStateCopyWithImpl<$Res, LoginState>;
}

/// @nodoc
class _$LoginStateCopyWithImpl<$Res, $Val extends LoginState> implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._value, this._then);

// ignore: unused_field
  final $Val _value;
// ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LoginInitialStateImplCopyWith<$Res> {
  factory _$$LoginInitialStateImplCopyWith(_$LoginInitialStateImpl value, $Res Function(_$LoginInitialStateImpl) then) =
      __$$LoginInitialStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoginInitialStateImplCopyWithImpl<$Res> extends _$LoginStateCopyWithImpl<$Res, _$LoginInitialStateImpl>
    implements _$$LoginInitialStateImplCopyWith<$Res> {
  __$$LoginInitialStateImplCopyWithImpl(_$LoginInitialStateImpl _value, $Res Function(_$LoginInitialStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoginInitialStateImpl extends _LoginInitialState {
  _$LoginInitialStateImpl() : super._();

  @override
  String toString() {
    return 'LoginState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$LoginInitialStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Failure failure) failure,
    required TResult Function() success,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function()? success,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Failure failure)? failure,
    TResult Function()? success,
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
    required TResult Function(_LoginInitialState value) initial,
    required TResult Function(_LoginLoadingState value) loading,
    required TResult Function(_LoginErrorState value) failure,
    required TResult Function(_LoginSuccessState value) success,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoginInitialState value)? initial,
    TResult? Function(_LoginLoadingState value)? loading,
    TResult? Function(_LoginErrorState value)? failure,
    TResult? Function(_LoginSuccessState value)? success,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoginInitialState value)? initial,
    TResult Function(_LoginLoadingState value)? loading,
    TResult Function(_LoginErrorState value)? failure,
    TResult Function(_LoginSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _LoginInitialState extends LoginState {
  factory _LoginInitialState() = _$LoginInitialStateImpl;
  _LoginInitialState._() : super._();
}

/// @nodoc
abstract class _$$LoginLoadingStateImplCopyWith<$Res> {
  factory _$$LoginLoadingStateImplCopyWith(_$LoginLoadingStateImpl value, $Res Function(_$LoginLoadingStateImpl) then) =
      __$$LoginLoadingStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoginLoadingStateImplCopyWithImpl<$Res> extends _$LoginStateCopyWithImpl<$Res, _$LoginLoadingStateImpl>
    implements _$$LoginLoadingStateImplCopyWith<$Res> {
  __$$LoginLoadingStateImplCopyWithImpl(_$LoginLoadingStateImpl _value, $Res Function(_$LoginLoadingStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoginLoadingStateImpl extends _LoginLoadingState {
  _$LoginLoadingStateImpl() : super._();

  @override
  String toString() {
    return 'LoginState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$LoginLoadingStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Failure failure) failure,
    required TResult Function() success,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function()? success,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Failure failure)? failure,
    TResult Function()? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoginInitialState value) initial,
    required TResult Function(_LoginLoadingState value) loading,
    required TResult Function(_LoginErrorState value) failure,
    required TResult Function(_LoginSuccessState value) success,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoginInitialState value)? initial,
    TResult? Function(_LoginLoadingState value)? loading,
    TResult? Function(_LoginErrorState value)? failure,
    TResult? Function(_LoginSuccessState value)? success,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoginInitialState value)? initial,
    TResult Function(_LoginLoadingState value)? loading,
    TResult Function(_LoginErrorState value)? failure,
    TResult Function(_LoginSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _LoginLoadingState extends LoginState {
  factory _LoginLoadingState() = _$LoginLoadingStateImpl;
  _LoginLoadingState._() : super._();
}

/// @nodoc
abstract class _$$LoginErrorStateImplCopyWith<$Res> {
  factory _$$LoginErrorStateImplCopyWith(_$LoginErrorStateImpl value, $Res Function(_$LoginErrorStateImpl) then) =
      __$$LoginErrorStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});

  $FailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$LoginErrorStateImplCopyWithImpl<$Res> extends _$LoginStateCopyWithImpl<$Res, _$LoginErrorStateImpl>
    implements _$$LoginErrorStateImplCopyWith<$Res> {
  __$$LoginErrorStateImplCopyWithImpl(_$LoginErrorStateImpl _value, $Res Function(_$LoginErrorStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$LoginErrorStateImpl(
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

class _$LoginErrorStateImpl extends _LoginErrorState {
  _$LoginErrorStateImpl(this.failure) : super._();

  @override
  final Failure failure;

  @override
  String toString() {
    return 'LoginState.failure(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginErrorStateImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginErrorStateImplCopyWith<_$LoginErrorStateImpl> get copyWith =>
      __$$LoginErrorStateImplCopyWithImpl<_$LoginErrorStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Failure failure) failure,
    required TResult Function() success,
  }) {
    return failure(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function()? success,
  }) {
    return failure?.call(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Failure failure)? failure,
    TResult Function()? success,
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
    required TResult Function(_LoginInitialState value) initial,
    required TResult Function(_LoginLoadingState value) loading,
    required TResult Function(_LoginErrorState value) failure,
    required TResult Function(_LoginSuccessState value) success,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoginInitialState value)? initial,
    TResult? Function(_LoginLoadingState value)? loading,
    TResult? Function(_LoginErrorState value)? failure,
    TResult? Function(_LoginSuccessState value)? success,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoginInitialState value)? initial,
    TResult Function(_LoginLoadingState value)? loading,
    TResult Function(_LoginErrorState value)? failure,
    TResult Function(_LoginSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _LoginErrorState extends LoginState {
  factory _LoginErrorState(final Failure failure) = _$LoginErrorStateImpl;
  _LoginErrorState._() : super._();

  Failure get failure;
  @JsonKey(ignore: true)
  _$$LoginErrorStateImplCopyWith<_$LoginErrorStateImpl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoginSuccessStateImplCopyWith<$Res> {
  factory _$$LoginSuccessStateImplCopyWith(_$LoginSuccessStateImpl value, $Res Function(_$LoginSuccessStateImpl) then) =
      __$$LoginSuccessStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoginSuccessStateImplCopyWithImpl<$Res> extends _$LoginStateCopyWithImpl<$Res, _$LoginSuccessStateImpl>
    implements _$$LoginSuccessStateImplCopyWith<$Res> {
  __$$LoginSuccessStateImplCopyWithImpl(_$LoginSuccessStateImpl _value, $Res Function(_$LoginSuccessStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoginSuccessStateImpl extends _LoginSuccessState {
  _$LoginSuccessStateImpl() : super._();

  @override
  String toString() {
    return 'LoginState.success()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$LoginSuccessStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Failure failure) failure,
    required TResult Function() success,
  }) {
    return success();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function()? success,
  }) {
    return success?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Failure failure)? failure,
    TResult Function()? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoginInitialState value) initial,
    required TResult Function(_LoginLoadingState value) loading,
    required TResult Function(_LoginErrorState value) failure,
    required TResult Function(_LoginSuccessState value) success,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoginInitialState value)? initial,
    TResult? Function(_LoginLoadingState value)? loading,
    TResult? Function(_LoginErrorState value)? failure,
    TResult? Function(_LoginSuccessState value)? success,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoginInitialState value)? initial,
    TResult Function(_LoginLoadingState value)? loading,
    TResult Function(_LoginErrorState value)? failure,
    TResult Function(_LoginSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _LoginSuccessState extends LoginState {
  factory _LoginSuccessState() = _$LoginSuccessStateImpl;
  _LoginSuccessState._() : super._();
}
