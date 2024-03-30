part of 'album_images_bloc.dart';

@freezed
class AlbumImagesEvent with _$AlbumImagesEvent {
  const factory AlbumImagesEvent.fetchImages({required int albumId}) = _FetchAlbumImagesEvent;
}
