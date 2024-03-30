part of 'album_content_bloc.dart';

@freezed
class AlbumContentState with _$AlbumContentState {
  factory AlbumContentState.initial() = _AlbumContentInitialState;

  factory AlbumContentState.loading({
    List<AlbumEntity>? subAlbums,
  }) = _AlbumContentLoadingState;

  factory AlbumContentState.failure(Failure failure) = _AlbumContentErrorState;

  factory AlbumContentState.success({
    required List<AlbumEntity> subAlbums,
  }) = _AlbumContentSuccessState;

  const AlbumContentState._();

  bool get isLoading => this is _AlbumContentLoadingState;
}
