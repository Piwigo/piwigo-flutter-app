part of 'album_images_bloc.dart';

@freezed
class AlbumImagesState with _$AlbumImagesState {
  factory AlbumImagesState.initial() = _AlbumImagesInitialState;

  factory AlbumImagesState.loading({
    List<ImageEntity>? images,
  }) = _AlbumImagesLoadingState;

  factory AlbumImagesState.failure(Failure failure) = _AlbumImagesErrorState;

  factory AlbumImagesState.success({
    required List<ImageEntity> images,
  }) = _AlbumImagesSuccessState;

  const AlbumImagesState._();

  bool get isLoading => this is _AlbumImagesLoadingState;
}
