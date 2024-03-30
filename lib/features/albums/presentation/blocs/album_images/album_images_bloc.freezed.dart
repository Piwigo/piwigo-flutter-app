// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'album_images_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AlbumImagesEvent {
  int get albumId => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int albumId) fetchImages,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int albumId)? fetchImages,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int albumId)? fetchImages,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchAlbumImagesEvent value) fetchImages,
  }) =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchAlbumImagesEvent value)? fetchImages,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchAlbumImagesEvent value)? fetchImages,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AlbumImagesEventCopyWith<AlbumImagesEvent> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlbumImagesEventCopyWith<$Res> {
  factory $AlbumImagesEventCopyWith(AlbumImagesEvent value, $Res Function(AlbumImagesEvent) then) =
      _$AlbumImagesEventCopyWithImpl<$Res, AlbumImagesEvent>;
  @useResult
  $Res call({int albumId});
}

/// @nodoc
class _$AlbumImagesEventCopyWithImpl<$Res, $Val extends AlbumImagesEvent> implements $AlbumImagesEventCopyWith<$Res> {
  _$AlbumImagesEventCopyWithImpl(this._value, this._then);

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
abstract class _$$FetchAlbumImagesEventImplCopyWith<$Res> implements $AlbumImagesEventCopyWith<$Res> {
  factory _$$FetchAlbumImagesEventImplCopyWith(
          _$FetchAlbumImagesEventImpl value, $Res Function(_$FetchAlbumImagesEventImpl) then) =
      __$$FetchAlbumImagesEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int albumId});
}

/// @nodoc
class __$$FetchAlbumImagesEventImplCopyWithImpl<$Res>
    extends _$AlbumImagesEventCopyWithImpl<$Res, _$FetchAlbumImagesEventImpl>
    implements _$$FetchAlbumImagesEventImplCopyWith<$Res> {
  __$$FetchAlbumImagesEventImplCopyWithImpl(
      _$FetchAlbumImagesEventImpl _value, $Res Function(_$FetchAlbumImagesEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? albumId = null,
  }) {
    return _then(_$FetchAlbumImagesEventImpl(
      albumId: null == albumId
          ? _value.albumId
          : albumId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FetchAlbumImagesEventImpl implements _FetchAlbumImagesEvent {
  const _$FetchAlbumImagesEventImpl({required this.albumId});

  @override
  final int albumId;

  @override
  String toString() {
    return 'AlbumImagesEvent.fetchImages(albumId: $albumId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchAlbumImagesEventImpl &&
            (identical(other.albumId, albumId) || other.albumId == albumId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, albumId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FetchAlbumImagesEventImplCopyWith<_$FetchAlbumImagesEventImpl> get copyWith =>
      __$$FetchAlbumImagesEventImplCopyWithImpl<_$FetchAlbumImagesEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int albumId) fetchImages,
  }) {
    return fetchImages(albumId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int albumId)? fetchImages,
  }) {
    return fetchImages?.call(albumId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int albumId)? fetchImages,
    required TResult orElse(),
  }) {
    if (fetchImages != null) {
      return fetchImages(albumId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchAlbumImagesEvent value) fetchImages,
  }) {
    return fetchImages(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchAlbumImagesEvent value)? fetchImages,
  }) {
    return fetchImages?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchAlbumImagesEvent value)? fetchImages,
    required TResult orElse(),
  }) {
    if (fetchImages != null) {
      return fetchImages(this);
    }
    return orElse();
  }
}

abstract class _FetchAlbumImagesEvent implements AlbumImagesEvent {
  const factory _FetchAlbumImagesEvent({required final int albumId}) = _$FetchAlbumImagesEventImpl;

  @override
  int get albumId;
  @override
  @JsonKey(ignore: true)
  _$$FetchAlbumImagesEventImplCopyWith<_$FetchAlbumImagesEventImpl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AlbumImagesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<ImageEntity>? images) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<ImageEntity> images) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<ImageEntity>? images)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<ImageEntity> images)? success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<ImageEntity>? images)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<ImageEntity> images)? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AlbumImagesInitialState value) initial,
    required TResult Function(_AlbumImagesLoadingState value) loading,
    required TResult Function(_AlbumImagesErrorState value) failure,
    required TResult Function(_AlbumImagesSuccessState value) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumImagesInitialState value)? initial,
    TResult? Function(_AlbumImagesLoadingState value)? loading,
    TResult? Function(_AlbumImagesErrorState value)? failure,
    TResult? Function(_AlbumImagesSuccessState value)? success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumImagesInitialState value)? initial,
    TResult Function(_AlbumImagesLoadingState value)? loading,
    TResult Function(_AlbumImagesErrorState value)? failure,
    TResult Function(_AlbumImagesSuccessState value)? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlbumImagesStateCopyWith<$Res> {
  factory $AlbumImagesStateCopyWith(AlbumImagesState value, $Res Function(AlbumImagesState) then) =
      _$AlbumImagesStateCopyWithImpl<$Res, AlbumImagesState>;
}

/// @nodoc
class _$AlbumImagesStateCopyWithImpl<$Res, $Val extends AlbumImagesState> implements $AlbumImagesStateCopyWith<$Res> {
  _$AlbumImagesStateCopyWithImpl(this._value, this._then);

// ignore: unused_field
  final $Val _value;
// ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AlbumImagesInitialStateImplCopyWith<$Res> {
  factory _$$AlbumImagesInitialStateImplCopyWith(
          _$AlbumImagesInitialStateImpl value, $Res Function(_$AlbumImagesInitialStateImpl) then) =
      __$$AlbumImagesInitialStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AlbumImagesInitialStateImplCopyWithImpl<$Res>
    extends _$AlbumImagesStateCopyWithImpl<$Res, _$AlbumImagesInitialStateImpl>
    implements _$$AlbumImagesInitialStateImplCopyWith<$Res> {
  __$$AlbumImagesInitialStateImplCopyWithImpl(
      _$AlbumImagesInitialStateImpl _value, $Res Function(_$AlbumImagesInitialStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AlbumImagesInitialStateImpl extends _AlbumImagesInitialState {
  _$AlbumImagesInitialStateImpl() : super._();

  @override
  String toString() {
    return 'AlbumImagesState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType && other is _$AlbumImagesInitialStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<ImageEntity>? images) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<ImageEntity> images) success,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<ImageEntity>? images)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<ImageEntity> images)? success,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<ImageEntity>? images)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<ImageEntity> images)? success,
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
    required TResult Function(_AlbumImagesInitialState value) initial,
    required TResult Function(_AlbumImagesLoadingState value) loading,
    required TResult Function(_AlbumImagesErrorState value) failure,
    required TResult Function(_AlbumImagesSuccessState value) success,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumImagesInitialState value)? initial,
    TResult? Function(_AlbumImagesLoadingState value)? loading,
    TResult? Function(_AlbumImagesErrorState value)? failure,
    TResult? Function(_AlbumImagesSuccessState value)? success,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumImagesInitialState value)? initial,
    TResult Function(_AlbumImagesLoadingState value)? loading,
    TResult Function(_AlbumImagesErrorState value)? failure,
    TResult Function(_AlbumImagesSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _AlbumImagesInitialState extends AlbumImagesState {
  factory _AlbumImagesInitialState() = _$AlbumImagesInitialStateImpl;
  _AlbumImagesInitialState._() : super._();
}

/// @nodoc
abstract class _$$AlbumImagesLoadingStateImplCopyWith<$Res> {
  factory _$$AlbumImagesLoadingStateImplCopyWith(
          _$AlbumImagesLoadingStateImpl value, $Res Function(_$AlbumImagesLoadingStateImpl) then) =
      __$$AlbumImagesLoadingStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<ImageEntity>? images});
}

/// @nodoc
class __$$AlbumImagesLoadingStateImplCopyWithImpl<$Res>
    extends _$AlbumImagesStateCopyWithImpl<$Res, _$AlbumImagesLoadingStateImpl>
    implements _$$AlbumImagesLoadingStateImplCopyWith<$Res> {
  __$$AlbumImagesLoadingStateImplCopyWithImpl(
      _$AlbumImagesLoadingStateImpl _value, $Res Function(_$AlbumImagesLoadingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = freezed,
  }) {
    return _then(_$AlbumImagesLoadingStateImpl(
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ImageEntity>?,
    ));
  }
}

/// @nodoc

class _$AlbumImagesLoadingStateImpl extends _AlbumImagesLoadingState {
  _$AlbumImagesLoadingStateImpl({final List<ImageEntity>? images})
      : _images = images,
        super._();

  final List<ImageEntity>? _images;
  @override
  List<ImageEntity>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
// ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AlbumImagesState.loading(images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlbumImagesLoadingStateImpl &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(_images));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlbumImagesLoadingStateImplCopyWith<_$AlbumImagesLoadingStateImpl> get copyWith =>
      __$$AlbumImagesLoadingStateImplCopyWithImpl<_$AlbumImagesLoadingStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<ImageEntity>? images) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<ImageEntity> images) success,
  }) {
    return loading(images);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<ImageEntity>? images)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<ImageEntity> images)? success,
  }) {
    return loading?.call(images);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<ImageEntity>? images)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<ImageEntity> images)? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(images);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AlbumImagesInitialState value) initial,
    required TResult Function(_AlbumImagesLoadingState value) loading,
    required TResult Function(_AlbumImagesErrorState value) failure,
    required TResult Function(_AlbumImagesSuccessState value) success,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumImagesInitialState value)? initial,
    TResult? Function(_AlbumImagesLoadingState value)? loading,
    TResult? Function(_AlbumImagesErrorState value)? failure,
    TResult? Function(_AlbumImagesSuccessState value)? success,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumImagesInitialState value)? initial,
    TResult Function(_AlbumImagesLoadingState value)? loading,
    TResult Function(_AlbumImagesErrorState value)? failure,
    TResult Function(_AlbumImagesSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _AlbumImagesLoadingState extends AlbumImagesState {
  factory _AlbumImagesLoadingState({final List<ImageEntity>? images}) = _$AlbumImagesLoadingStateImpl;
  _AlbumImagesLoadingState._() : super._();

  List<ImageEntity>? get images;
  @JsonKey(ignore: true)
  _$$AlbumImagesLoadingStateImplCopyWith<_$AlbumImagesLoadingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AlbumImagesErrorStateImplCopyWith<$Res> {
  factory _$$AlbumImagesErrorStateImplCopyWith(
          _$AlbumImagesErrorStateImpl value, $Res Function(_$AlbumImagesErrorStateImpl) then) =
      __$$AlbumImagesErrorStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});

  $FailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$AlbumImagesErrorStateImplCopyWithImpl<$Res>
    extends _$AlbumImagesStateCopyWithImpl<$Res, _$AlbumImagesErrorStateImpl>
    implements _$$AlbumImagesErrorStateImplCopyWith<$Res> {
  __$$AlbumImagesErrorStateImplCopyWithImpl(
      _$AlbumImagesErrorStateImpl _value, $Res Function(_$AlbumImagesErrorStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$AlbumImagesErrorStateImpl(
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

class _$AlbumImagesErrorStateImpl extends _AlbumImagesErrorState {
  _$AlbumImagesErrorStateImpl(this.failure) : super._();

  @override
  final Failure failure;

  @override
  String toString() {
    return 'AlbumImagesState.failure(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlbumImagesErrorStateImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlbumImagesErrorStateImplCopyWith<_$AlbumImagesErrorStateImpl> get copyWith =>
      __$$AlbumImagesErrorStateImplCopyWithImpl<_$AlbumImagesErrorStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<ImageEntity>? images) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<ImageEntity> images) success,
  }) {
    return failure(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<ImageEntity>? images)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<ImageEntity> images)? success,
  }) {
    return failure?.call(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<ImageEntity>? images)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<ImageEntity> images)? success,
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
    required TResult Function(_AlbumImagesInitialState value) initial,
    required TResult Function(_AlbumImagesLoadingState value) loading,
    required TResult Function(_AlbumImagesErrorState value) failure,
    required TResult Function(_AlbumImagesSuccessState value) success,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumImagesInitialState value)? initial,
    TResult? Function(_AlbumImagesLoadingState value)? loading,
    TResult? Function(_AlbumImagesErrorState value)? failure,
    TResult? Function(_AlbumImagesSuccessState value)? success,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumImagesInitialState value)? initial,
    TResult Function(_AlbumImagesLoadingState value)? loading,
    TResult Function(_AlbumImagesErrorState value)? failure,
    TResult Function(_AlbumImagesSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _AlbumImagesErrorState extends AlbumImagesState {
  factory _AlbumImagesErrorState(final Failure failure) = _$AlbumImagesErrorStateImpl;
  _AlbumImagesErrorState._() : super._();

  Failure get failure;
  @JsonKey(ignore: true)
  _$$AlbumImagesErrorStateImplCopyWith<_$AlbumImagesErrorStateImpl> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AlbumImagesSuccessStateImplCopyWith<$Res> {
  factory _$$AlbumImagesSuccessStateImplCopyWith(
          _$AlbumImagesSuccessStateImpl value, $Res Function(_$AlbumImagesSuccessStateImpl) then) =
      __$$AlbumImagesSuccessStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<ImageEntity> images});
}

/// @nodoc
class __$$AlbumImagesSuccessStateImplCopyWithImpl<$Res>
    extends _$AlbumImagesStateCopyWithImpl<$Res, _$AlbumImagesSuccessStateImpl>
    implements _$$AlbumImagesSuccessStateImplCopyWith<$Res> {
  __$$AlbumImagesSuccessStateImplCopyWithImpl(
      _$AlbumImagesSuccessStateImpl _value, $Res Function(_$AlbumImagesSuccessStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
  }) {
    return _then(_$AlbumImagesSuccessStateImpl(
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<ImageEntity>,
    ));
  }
}

/// @nodoc

class _$AlbumImagesSuccessStateImpl extends _AlbumImagesSuccessState {
  _$AlbumImagesSuccessStateImpl({required final List<ImageEntity> images})
      : _images = images,
        super._();

  final List<ImageEntity> _images;
  @override
  List<ImageEntity> get images {
    if (_images is EqualUnmodifiableListView) return _images;
// ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString() {
    return 'AlbumImagesState.success(images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlbumImagesSuccessStateImpl &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(_images));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlbumImagesSuccessStateImplCopyWith<_$AlbumImagesSuccessStateImpl> get copyWith =>
      __$$AlbumImagesSuccessStateImplCopyWithImpl<_$AlbumImagesSuccessStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(List<ImageEntity>? images) loading,
    required TResult Function(Failure failure) failure,
    required TResult Function(List<ImageEntity> images) success,
  }) {
    return success(images);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<ImageEntity>? images)? loading,
    TResult? Function(Failure failure)? failure,
    TResult? Function(List<ImageEntity> images)? success,
  }) {
    return success?.call(images);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<ImageEntity>? images)? loading,
    TResult Function(Failure failure)? failure,
    TResult Function(List<ImageEntity> images)? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(images);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AlbumImagesInitialState value) initial,
    required TResult Function(_AlbumImagesLoadingState value) loading,
    required TResult Function(_AlbumImagesErrorState value) failure,
    required TResult Function(_AlbumImagesSuccessState value) success,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AlbumImagesInitialState value)? initial,
    TResult? Function(_AlbumImagesLoadingState value)? loading,
    TResult? Function(_AlbumImagesErrorState value)? failure,
    TResult? Function(_AlbumImagesSuccessState value)? success,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AlbumImagesInitialState value)? initial,
    TResult Function(_AlbumImagesLoadingState value)? loading,
    TResult Function(_AlbumImagesErrorState value)? failure,
    TResult Function(_AlbumImagesSuccessState value)? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _AlbumImagesSuccessState extends AlbumImagesState {
  factory _AlbumImagesSuccessState({required final List<ImageEntity> images}) = _$AlbumImagesSuccessStateImpl;
  _AlbumImagesSuccessState._() : super._();

  List<ImageEntity> get images;
  @JsonKey(ignore: true)
  _$$AlbumImagesSuccessStateImplCopyWith<_$AlbumImagesSuccessStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
