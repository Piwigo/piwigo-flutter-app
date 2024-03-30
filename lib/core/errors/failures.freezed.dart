// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Failure {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unknown,
    required TResult Function() connectivity,
    required TResult Function(DioError error) dio,
    required TResult Function() invalidCredentials,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unknown,
    TResult? Function()? connectivity,
    TResult? Function(DioError error)? dio,
    TResult? Function()? invalidCredentials,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unknown,
    TResult Function()? connectivity,
    TResult Function(DioError error)? dio,
    TResult Function()? invalidCredentials,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UnknownFailure value) unknown,
    required TResult Function(ConnectivityFailure value) connectivity,
    required TResult Function(DioFailure value) dio,
    required TResult Function(InvalidCredentialsFailure value) invalidCredentials,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UnknownFailure value)? unknown,
    TResult? Function(ConnectivityFailure value)? connectivity,
    TResult? Function(DioFailure value)? dio,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UnknownFailure value)? unknown,
    TResult Function(ConnectivityFailure value)? connectivity,
    TResult Function(DioFailure value)? dio,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) = _$FailureCopyWithImpl<$Res, Failure>;
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure> implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

// ignore: unused_field
  final $Val _value;
// ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(_$UnknownFailureImpl value, $Res Function(_$UnknownFailureImpl) then) =
      __$$UnknownFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res> extends _$FailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(_$UnknownFailureImpl _value, $Res Function(_$UnknownFailureImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$UnknownFailureImpl extends _UnknownFailure {
  const _$UnknownFailureImpl() : super._();

  @override
  String toString() {
    return 'Failure.unknown()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$UnknownFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unknown,
    required TResult Function() connectivity,
    required TResult Function(DioError error) dio,
    required TResult Function() invalidCredentials,
  }) {
    return unknown();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unknown,
    TResult? Function()? connectivity,
    TResult? Function(DioError error)? dio,
    TResult? Function()? invalidCredentials,
  }) {
    return unknown?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unknown,
    TResult Function()? connectivity,
    TResult Function(DioError error)? dio,
    TResult Function()? invalidCredentials,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UnknownFailure value) unknown,
    required TResult Function(ConnectivityFailure value) connectivity,
    required TResult Function(DioFailure value) dio,
    required TResult Function(InvalidCredentialsFailure value) invalidCredentials,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UnknownFailure value)? unknown,
    TResult? Function(ConnectivityFailure value)? connectivity,
    TResult? Function(DioFailure value)? dio,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UnknownFailure value)? unknown,
    TResult Function(ConnectivityFailure value)? connectivity,
    TResult Function(DioFailure value)? dio,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class _UnknownFailure extends Failure {
  const factory _UnknownFailure() = _$UnknownFailureImpl;
  const _UnknownFailure._() : super._();
}

/// @nodoc
abstract class _$$ConnectivityFailureImplCopyWith<$Res> {
  factory _$$ConnectivityFailureImplCopyWith(
          _$ConnectivityFailureImpl value, $Res Function(_$ConnectivityFailureImpl) then) =
      __$$ConnectivityFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ConnectivityFailureImplCopyWithImpl<$Res> extends _$FailureCopyWithImpl<$Res, _$ConnectivityFailureImpl>
    implements _$$ConnectivityFailureImplCopyWith<$Res> {
  __$$ConnectivityFailureImplCopyWithImpl(
      _$ConnectivityFailureImpl _value, $Res Function(_$ConnectivityFailureImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ConnectivityFailureImpl extends ConnectivityFailure {
  const _$ConnectivityFailureImpl() : super._();

  @override
  String toString() {
    return 'Failure.connectivity()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$ConnectivityFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unknown,
    required TResult Function() connectivity,
    required TResult Function(DioError error) dio,
    required TResult Function() invalidCredentials,
  }) {
    return connectivity();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unknown,
    TResult? Function()? connectivity,
    TResult? Function(DioError error)? dio,
    TResult? Function()? invalidCredentials,
  }) {
    return connectivity?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unknown,
    TResult Function()? connectivity,
    TResult Function(DioError error)? dio,
    TResult Function()? invalidCredentials,
    required TResult orElse(),
  }) {
    if (connectivity != null) {
      return connectivity();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UnknownFailure value) unknown,
    required TResult Function(ConnectivityFailure value) connectivity,
    required TResult Function(DioFailure value) dio,
    required TResult Function(InvalidCredentialsFailure value) invalidCredentials,
  }) {
    return connectivity(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UnknownFailure value)? unknown,
    TResult? Function(ConnectivityFailure value)? connectivity,
    TResult? Function(DioFailure value)? dio,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
  }) {
    return connectivity?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UnknownFailure value)? unknown,
    TResult Function(ConnectivityFailure value)? connectivity,
    TResult Function(DioFailure value)? dio,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    required TResult orElse(),
  }) {
    if (connectivity != null) {
      return connectivity(this);
    }
    return orElse();
  }
}

abstract class ConnectivityFailure extends Failure {
  const factory ConnectivityFailure() = _$ConnectivityFailureImpl;
  const ConnectivityFailure._() : super._();
}

/// @nodoc
abstract class _$$DioFailureImplCopyWith<$Res> {
  factory _$$DioFailureImplCopyWith(_$DioFailureImpl value, $Res Function(_$DioFailureImpl) then) =
      __$$DioFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DioError error});
}

/// @nodoc
class __$$DioFailureImplCopyWithImpl<$Res> extends _$FailureCopyWithImpl<$Res, _$DioFailureImpl>
    implements _$$DioFailureImplCopyWith<$Res> {
  __$$DioFailureImplCopyWithImpl(_$DioFailureImpl _value, $Res Function(_$DioFailureImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$DioFailureImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as DioError,
    ));
  }
}

/// @nodoc

class _$DioFailureImpl extends DioFailure {
  const _$DioFailureImpl(this.error) : super._();

  @override
  final DioError error;

  @override
  String toString() {
    return 'Failure.dio(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DioFailureImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DioFailureImplCopyWith<_$DioFailureImpl> get copyWith =>
      __$$DioFailureImplCopyWithImpl<_$DioFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unknown,
    required TResult Function() connectivity,
    required TResult Function(DioError error) dio,
    required TResult Function() invalidCredentials,
  }) {
    return dio(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unknown,
    TResult? Function()? connectivity,
    TResult? Function(DioError error)? dio,
    TResult? Function()? invalidCredentials,
  }) {
    return dio?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unknown,
    TResult Function()? connectivity,
    TResult Function(DioError error)? dio,
    TResult Function()? invalidCredentials,
    required TResult orElse(),
  }) {
    if (dio != null) {
      return dio(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UnknownFailure value) unknown,
    required TResult Function(ConnectivityFailure value) connectivity,
    required TResult Function(DioFailure value) dio,
    required TResult Function(InvalidCredentialsFailure value) invalidCredentials,
  }) {
    return dio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UnknownFailure value)? unknown,
    TResult? Function(ConnectivityFailure value)? connectivity,
    TResult? Function(DioFailure value)? dio,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
  }) {
    return dio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UnknownFailure value)? unknown,
    TResult Function(ConnectivityFailure value)? connectivity,
    TResult Function(DioFailure value)? dio,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    required TResult orElse(),
  }) {
    if (dio != null) {
      return dio(this);
    }
    return orElse();
  }
}

abstract class DioFailure extends Failure {
  const factory DioFailure(final DioError error) = _$DioFailureImpl;
  const DioFailure._() : super._();

  DioError get error;
  @JsonKey(ignore: true)
  _$$DioFailureImplCopyWith<_$DioFailureImpl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$InvalidCredentialsFailureImplCopyWith<$Res> {
  factory _$$InvalidCredentialsFailureImplCopyWith(
          _$InvalidCredentialsFailureImpl value, $Res Function(_$InvalidCredentialsFailureImpl) then) =
      __$$InvalidCredentialsFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InvalidCredentialsFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$InvalidCredentialsFailureImpl>
    implements _$$InvalidCredentialsFailureImplCopyWith<$Res> {
  __$$InvalidCredentialsFailureImplCopyWithImpl(
      _$InvalidCredentialsFailureImpl _value, $Res Function(_$InvalidCredentialsFailureImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InvalidCredentialsFailureImpl extends InvalidCredentialsFailure {
  const _$InvalidCredentialsFailureImpl() : super._();

  @override
  String toString() {
    return 'Failure.invalidCredentials()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$InvalidCredentialsFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unknown,
    required TResult Function() connectivity,
    required TResult Function(DioError error) dio,
    required TResult Function() invalidCredentials,
  }) {
    return invalidCredentials();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unknown,
    TResult? Function()? connectivity,
    TResult? Function(DioError error)? dio,
    TResult? Function()? invalidCredentials,
  }) {
    return invalidCredentials?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unknown,
    TResult Function()? connectivity,
    TResult Function(DioError error)? dio,
    TResult Function()? invalidCredentials,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UnknownFailure value) unknown,
    required TResult Function(ConnectivityFailure value) connectivity,
    required TResult Function(DioFailure value) dio,
    required TResult Function(InvalidCredentialsFailure value) invalidCredentials,
  }) {
    return invalidCredentials(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UnknownFailure value)? unknown,
    TResult? Function(ConnectivityFailure value)? connectivity,
    TResult? Function(DioFailure value)? dio,
    TResult? Function(InvalidCredentialsFailure value)? invalidCredentials,
  }) {
    return invalidCredentials?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UnknownFailure value)? unknown,
    TResult Function(ConnectivityFailure value)? connectivity,
    TResult Function(DioFailure value)? dio,
    TResult Function(InvalidCredentialsFailure value)? invalidCredentials,
    required TResult orElse(),
  }) {
    if (invalidCredentials != null) {
      return invalidCredentials(this);
    }
    return orElse();
  }
}

abstract class InvalidCredentialsFailure extends Failure {
  const factory InvalidCredentialsFailure() = _$InvalidCredentialsFailureImpl;
  const InvalidCredentialsFailure._() : super._();
}
