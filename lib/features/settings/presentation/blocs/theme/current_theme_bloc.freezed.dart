// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'current_theme_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$CurrentThemeState {
  ThemeMode get mode => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CurrentThemeStateCopyWith<CurrentThemeState> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentThemeStateCopyWith<$Res> {
  factory $CurrentThemeStateCopyWith(CurrentThemeState value, $Res Function(CurrentThemeState) then) =
      _$CurrentThemeStateCopyWithImpl<$Res, CurrentThemeState>;

  @useResult
  $Res call({ThemeMode mode});
}

/// @nodoc
class _$CurrentThemeStateCopyWithImpl<$Res, $Val extends CurrentThemeState>
    implements $CurrentThemeStateCopyWith<$Res> {
  _$CurrentThemeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CurrentThemeStateImplCopyWith<$Res> implements $CurrentThemeStateCopyWith<$Res> {
  factory _$$CurrentThemeStateImplCopyWith(_$CurrentThemeStateImpl value, $Res Function(_$CurrentThemeStateImpl) then) =
      __$$CurrentThemeStateImplCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({ThemeMode mode});
}

/// @nodoc
class __$$CurrentThemeStateImplCopyWithImpl<$Res> extends _$CurrentThemeStateCopyWithImpl<$Res, _$CurrentThemeStateImpl>
    implements _$$CurrentThemeStateImplCopyWith<$Res> {
  __$$CurrentThemeStateImplCopyWithImpl(_$CurrentThemeStateImpl _value, $Res Function(_$CurrentThemeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
  }) {
    return _then(_$CurrentThemeStateImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as ThemeMode,
    ));
  }
}

/// @nodoc

class _$CurrentThemeStateImpl implements _CurrentThemeState {
  const _$CurrentThemeStateImpl({required this.mode});

  @override
  final ThemeMode mode;

  @override
  String toString() {
    return 'CurrentThemeState(mode: $mode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrentThemeStateImpl &&
            (identical(other.mode, mode) || other.mode == mode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, mode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrentThemeStateImplCopyWith<_$CurrentThemeStateImpl> get copyWith =>
      __$$CurrentThemeStateImplCopyWithImpl<_$CurrentThemeStateImpl>(this, _$identity);
}

abstract class _CurrentThemeState implements CurrentThemeState {
  const factory _CurrentThemeState({required final ThemeMode mode}) = _$CurrentThemeStateImpl;

  @override
  ThemeMode get mode;

  @override
  @JsonKey(ignore: true)
  _$$CurrentThemeStateImplCopyWith<_$CurrentThemeStateImpl> get copyWith => throw _privateConstructorUsedError;
}
