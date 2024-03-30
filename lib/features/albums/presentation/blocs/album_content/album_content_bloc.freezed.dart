// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'album_content_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AlbumContentEvent {
  int get albumId => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int albumId) getAlbum,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int albumId)? getAlbum,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int albumId)? getAlbum,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetAlbumEvent value) getAlbum,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetAlbumEvent value)? getAlbum,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetAlbumEvent value)? getAlbum,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AlbumContentEventCopyWith<AlbumContentEvent> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlbumContentEventCopyWith<$Res> {
  factory $AlbumContentEventCopyWith(AlbumContentEvent value, $Res Function(AlbumContentEvent) then) =
      _$AlbumContentEventCopyWithImpl<$Res, AlbumContentEvent>;
  @useResult
  $Res call({int albumId});
}

/// @nodoc
class _$AlbumContentEventCopyWithImpl<$Res, $Val extends AlbumContentEvent>
    implements $AlbumContentEventCopyWith<$Res> {
  _$AlbumContentEventCopyWithImpl(this._value, this._then);

// ignore: unused_field
  final $Val _value;
// ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? albumId = null,
  }) {
    return _then(_value.copyWith(
      albumId: null == albumId
          ? _value.albumId
          : albumId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GetAlbumEventImplCopyWith<$Res> implements $AlbumContentEventCopyWith<$Res> {
  factory _$$GetAlbumEventImplCopyWith(_$GetAlbumEventImpl value, $Res Function(_$GetAlbumEventImpl) then) =
      __$$GetAlbumEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int albumId});
}

/// @nodoc
class __$$GetAlbumEventImplCopyWithImpl<$Res> extends _$AlbumContentEventCopyWithImpl<$Res, _$GetAlbumEventImpl>
    implements _$$GetAlbumEventImplCopyWith<$Res> {
  __$$GetAlbumEventImplCopyWithImpl(_$GetAlbumEventImpl _value, $Res Function(_$GetAlbumEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? albumId = null,
  }) {
    return _then(_$GetAlbumEventImpl(
      albumId: null == albumId
          ? _value.albumId
          : albumId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$GetAlbumEventImpl implements _GetAlbumEvent {
  const _$GetAlbumEventImpl({required this.albumId});

  @override
  final int albumId;

  @override
  String toString() {
    return 'AlbumContentEvent.getAlbum(albumId: $albumId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetAlbumEventImpl &&
            (identical(other.albumId, albumId) || other.albumId == albumId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, albumId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetAlbumEventImplCopyWith<_$GetAlbumEventImpl> get copyWith =>
      __$$GetAlbumEventImplCopyWithImpl<_$GetAlbumEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int albumId) getAlbum,
  }) {
    return getAlbum(albumId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int albumId)? getAlbum,
  }) {
    return getAlbum?.call(albumId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int albumId)? getAlbum,
    required TResult orElse(),
  }) {
    if (getAlbum != null) {
      return getAlbum(albumId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetAlbumEvent value) getAlbum,
  }) {
    return getAlbum(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetAlbumEvent value)? getAlbum,
  }) {
    return getAlbum?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetAlbumEvent value)? getAlbum,
    required TResult orElse(),
  }) {
    if (getAlbum != null) {
      return getAlbum(this);
    }
    return orElse();
  }
}

abstract class _GetAlbumEvent implements AlbumContentEvent {
  const factory _GetAlbumEvent({required final int albumId}) = _$GetAlbumEventImpl;

  @override
  int get albumId;
  @override
  @JsonKey(ignore: true)
  _$$GetAlbumEventImplCopyWith<_$GetAlbumEventImpl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AlbumContentState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<AlbumEntity>? subAlbums) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<AlbumEntity> subAlbums) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<AlbumEntity>? subAlbums)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<AlbumEntity> subAlbums)? success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<AlbumEntity>? subAlbums)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<AlbumEntity> subAlbums)? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AlbumContentInitialState value) initial,
    required TResult Function(_AlbumContentLoadingState value) loading,
    required TResult Function(_AlbumContentErrorState value) failure,
    required TResult Function(_AlbumContentSuccessState value) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumContentInitialState value)? initial,
    TResult? Function(_AlbumContentLoadingState value)? loading,
    TResult? Function(_AlbumContentErrorState value)? failure,
    TResult? Function(_AlbumContentSuccessState value)? success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumContentInitialState value)? initial,
    TResult Function(_AlbumContentLoadingState value)? loading,
    TResult Function(_AlbumContentErrorState value)? failure,
    TResult Function(_AlbumContentSuccessState value)? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlbumContentStateCopyWith<$Res> {
  factory $AlbumContentStateCopyWith(AlbumContentState value, $Res Function(AlbumContentState) then) =
      _$AlbumContentStateCopyWithImpl<$Res, AlbumContentState>;
}

/// @nodoc
class _$AlbumContentStateCopyWithImpl<$Res, $Val extends AlbumContentState>
    implements $AlbumContentStateCopyWith<$Res> {
  _$AlbumContentStateCopyWithImpl(this._value, this._then);

// ignore: unused_field
  final $Val _value;
// ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AlbumContentInitialStateImplCopyWith<$Res> {
  factory _$$AlbumContentInitialStateImplCopyWith(
          _$AlbumContentInitialStateImpl value, $Res Function(_$AlbumContentInitialStateImpl) then) =
      __$$AlbumContentInitialStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AlbumContentInitialStateImplCopyWithImpl<$Res>
    extends _$AlbumContentStateCopyWithImpl<$Res, _$AlbumContentInitialStateImpl>
    implements _$$AlbumContentInitialStateImplCopyWith<$Res> {
  __$$AlbumContentInitialStateImplCopyWithImpl(
      _$AlbumContentInitialStateImpl _value, $Res Function(_$AlbumContentInitialStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AlbumContentInitialStateImpl extends _AlbumContentInitialState {
  _$AlbumContentInitialStateImpl() : super._();

  @override
  String toString() {
    return 'AlbumContentState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$AlbumContentInitialStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<AlbumEntity>? subAlbums) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<AlbumEntity> subAlbums) success,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<AlbumEntity>? subAlbums)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<AlbumEntity> subAlbums)? success,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<AlbumEntity>? subAlbums)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<AlbumEntity> subAlbums)? success,
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
    required TResult Function(_AlbumContentInitialState value) initial,
    required TResult Function(_AlbumContentLoadingState value) loading,
    required TResult Function(_AlbumContentErrorState value) failure,
    required TResult Function(_AlbumContentSuccessState value) success,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumContentInitialState value)? initial,
    TResult? Function(_AlbumContentLoadingState value)? loading,
    TResult? Function(_AlbumContentErrorState value)? failure,
    TResult? Function(_AlbumContentSuccessState value)? success,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumContentInitialState value)? initial,
    TResult Function(_AlbumContentLoadingState value)? loading,
    TResult Function(_AlbumContentErrorState value)? failure,
    TResult Function(_AlbumContentSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _AlbumContentInitialState extends AlbumContentState {
  factory _AlbumContentInitialState() = _$AlbumContentInitialStateImpl;
  _AlbumContentInitialState._() : super._();
}

/// @nodoc
abstract class _$$AlbumContentLoadingStateImplCopyWith<$Res> {
  factory _$$AlbumContentLoadingStateImplCopyWith(
          _$AlbumContentLoadingStateImpl value, $Res Function(_$AlbumContentLoadingStateImpl) then) =
      __$$AlbumContentLoadingStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<AlbumEntity>? subAlbums});
}

/// @nodoc
class __$$AlbumContentLoadingStateImplCopyWithImpl<$Res>
    extends _$AlbumContentStateCopyWithImpl<$Res, _$AlbumContentLoadingStateImpl>
    implements _$$AlbumContentLoadingStateImplCopyWith<$Res> {
  __$$AlbumContentLoadingStateImplCopyWithImpl(
      _$AlbumContentLoadingStateImpl _value, $Res Function(_$AlbumContentLoadingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subAlbums = freezed,
  }) {
    return _then(_$AlbumContentLoadingStateImpl(
      subAlbums: freezed == subAlbums
          ? _value._subAlbums
          : subAlbums // ignore: cast_nullable_to_non_nullable
              as List<AlbumEntity>?,
    ));
  }
}

/// @nodoc

class _$AlbumContentLoadingStateImpl extends _AlbumContentLoadingState {
  _$AlbumContentLoadingStateImpl({final List<AlbumEntity>? subAlbums})
      : _subAlbums = subAlbums,
        super._();

  final List<AlbumEntity>? _subAlbums;
  @override
  List<AlbumEntity>? get subAlbums {
    final value = _subAlbums;
    if (value == null) return null;
    if (_subAlbums is EqualUnmodifiableListView) return _subAlbums;
// ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AlbumContentState.loading(subAlbums: $subAlbums)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlbumContentLoadingStateImpl &&
            const DeepCollectionEquality().equals(other._subAlbums, _subAlbums));
  }

  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(_subAlbums));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlbumContentLoadingStateImplCopyWith<_$AlbumContentLoadingStateImpl> get copyWith =>
      __$$AlbumContentLoadingStateImplCopyWithImpl<_$AlbumContentLoadingStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<AlbumEntity>? subAlbums) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<AlbumEntity> subAlbums) success,
  }) {
    return loading(subAlbums);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<AlbumEntity>? subAlbums)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<AlbumEntity> subAlbums)? success,
  }) {
    return loading?.call(subAlbums);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<AlbumEntity>? subAlbums)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<AlbumEntity> subAlbums)? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(subAlbums);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AlbumContentInitialState value) initial,
    required TResult Function(_AlbumContentLoadingState value) loading,
    required TResult Function(_AlbumContentErrorState value) failure,
    required TResult Function(_AlbumContentSuccessState value) success,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumContentInitialState value)? initial,
    TResult? Function(_AlbumContentLoadingState value)? loading,
    TResult? Function(_AlbumContentErrorState value)? failure,
    TResult? Function(_AlbumContentSuccessState value)? success,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumContentInitialState value)? initial,
    TResult Function(_AlbumContentLoadingState value)? loading,
    TResult Function(_AlbumContentErrorState value)? failure,
    TResult Function(_AlbumContentSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _AlbumContentLoadingState extends AlbumContentState {
  factory _AlbumContentLoadingState({final List<AlbumEntity>? subAlbums}) = _$AlbumContentLoadingStateImpl;
  _AlbumContentLoadingState._() : super._();

  List<AlbumEntity>? get subAlbums;
  @JsonKey(ignore: true)
  _$$AlbumContentLoadingStateImplCopyWith<_$AlbumContentLoadingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AlbumContentErrorStateImplCopyWith<$Res> {
  factory _$$AlbumContentErrorStateImplCopyWith(
          _$AlbumContentErrorStateImpl value, $Res Function(_$AlbumContentErrorStateImpl) then) =
      __$$AlbumContentErrorStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});

  $FailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$AlbumContentErrorStateImplCopyWithImpl<$Res>
    extends _$AlbumContentStateCopyWithImpl<$Res, _$AlbumContentErrorStateImpl>
    implements _$$AlbumContentErrorStateImplCopyWith<$Res> {
  __$$AlbumContentErrorStateImplCopyWithImpl(
      _$AlbumContentErrorStateImpl _value, $Res Function(_$AlbumContentErrorStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$AlbumContentErrorStateImpl(
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

class _$AlbumContentErrorStateImpl extends _AlbumContentErrorState {
  _$AlbumContentErrorStateImpl(this.failure) : super._();

  @override
  final Failure failure;

  @override
  String toString() {
    return 'AlbumContentState.failure(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlbumContentErrorStateImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlbumContentErrorStateImplCopyWith<_$AlbumContentErrorStateImpl> get copyWith =>
      __$$AlbumContentErrorStateImplCopyWithImpl<_$AlbumContentErrorStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<AlbumEntity>? subAlbums) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<AlbumEntity> subAlbums) success,
  }) {
    return failure(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<AlbumEntity>? subAlbums)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<AlbumEntity> subAlbums)? success,
  }) {
    return failure?.call(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<AlbumEntity>? subAlbums)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<AlbumEntity> subAlbums)? success,
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
    required TResult Function(_AlbumContentInitialState value) initial,
    required TResult Function(_AlbumContentLoadingState value) loading,
    required TResult Function(_AlbumContentErrorState value) failure,
    required TResult Function(_AlbumContentSuccessState value) success,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumContentInitialState value)? initial,
    TResult? Function(_AlbumContentLoadingState value)? loading,
    TResult? Function(_AlbumContentErrorState value)? failure,
    TResult? Function(_AlbumContentSuccessState value)? success,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumContentInitialState value)? initial,
    TResult Function(_AlbumContentLoadingState value)? loading,
    TResult Function(_AlbumContentErrorState value)? failure,
    TResult Function(_AlbumContentSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _AlbumContentErrorState extends AlbumContentState {
  factory _AlbumContentErrorState(final Failure failure) = _$AlbumContentErrorStateImpl;
  _AlbumContentErrorState._() : super._();

  Failure get failure;
  @JsonKey(ignore: true)
  _$$AlbumContentErrorStateImplCopyWith<_$AlbumContentErrorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AlbumContentSuccessStateImplCopyWith<$Res> {
  factory _$$AlbumContentSuccessStateImplCopyWith(
          _$AlbumContentSuccessStateImpl value, $Res Function(_$AlbumContentSuccessStateImpl) then) =
      __$$AlbumContentSuccessStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<AlbumEntity> subAlbums});
}

/// @nodoc
class __$$AlbumContentSuccessStateImplCopyWithImpl<$Res>
    extends _$AlbumContentStateCopyWithImpl<$Res, _$AlbumContentSuccessStateImpl>
    implements _$$AlbumContentSuccessStateImplCopyWith<$Res> {
  __$$AlbumContentSuccessStateImplCopyWithImpl(
      _$AlbumContentSuccessStateImpl _value, $Res Function(_$AlbumContentSuccessStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subAlbums = null,
  }) {
    return _then(_$AlbumContentSuccessStateImpl(
      subAlbums: null == subAlbums
          ? _value._subAlbums
          : subAlbums // ignore: cast_nullable_to_non_nullable
              as List<AlbumEntity>,
    ));
  }
}

/// @nodoc

class _$AlbumContentSuccessStateImpl extends _AlbumContentSuccessState {
  _$AlbumContentSuccessStateImpl({required final List<AlbumEntity> subAlbums})
      : _subAlbums = subAlbums,
        super._();

  final List<AlbumEntity> _subAlbums;
  @override
  List<AlbumEntity> get subAlbums {
    if (_subAlbums is EqualUnmodifiableListView) return _subAlbums;
// ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subAlbums);
  }

  @override
  String toString() {
    return 'AlbumContentState.success(subAlbums: $subAlbums)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlbumContentSuccessStateImpl &&
            const DeepCollectionEquality().equals(other._subAlbums, _subAlbums));
  }

  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(_subAlbums));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlbumContentSuccessStateImplCopyWith<_$AlbumContentSuccessStateImpl> get copyWith =>
      __$$AlbumContentSuccessStateImplCopyWithImpl<_$AlbumContentSuccessStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<AlbumEntity>? subAlbums) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<AlbumEntity> subAlbums) success,
  }) {
    return success(subAlbums);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<AlbumEntity>? subAlbums)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<AlbumEntity> subAlbums)? success,
  }) {
    return success?.call(subAlbums);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<AlbumEntity>? subAlbums)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<AlbumEntity> subAlbums)? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(subAlbums);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AlbumContentInitialState value) initial,
    required TResult Function(_AlbumContentLoadingState value) loading,
    required TResult Function(_AlbumContentErrorState value) failure,
    required TResult Function(_AlbumContentSuccessState value) success,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumContentInitialState value)? initial,
    TResult? Function(_AlbumContentLoadingState value)? loading,
    TResult? Function(_AlbumContentErrorState value)? failure,
    TResult? Function(_AlbumContentSuccessState value)? success,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumContentInitialState value)? initial,
    TResult Function(_AlbumContentLoadingState value)? loading,
    TResult Function(_AlbumContentErrorState value)? failure,
    TResult Function(_AlbumContentSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _AlbumContentSuccessState extends AlbumContentState {
  factory _AlbumContentSuccessState({required final List<AlbumEntity> subAlbums}) = _$AlbumContentSuccessStateImpl;
  _AlbumContentSuccessState._() : super._();

  List<AlbumEntity> get subAlbums;
  @JsonKey(ignore: true)
  _$$AlbumContentSuccessStateImplCopyWith<_$AlbumContentSuccessStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
