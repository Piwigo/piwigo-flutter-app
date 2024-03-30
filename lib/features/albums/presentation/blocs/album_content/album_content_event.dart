part of 'album_content_bloc.dart';

@freezed
class AlbumContentEvent with _$AlbumContentEvent {
  const factory AlbumContentEvent.getAlbum({required int albumId}) = _GetAlbumEvent;
}
