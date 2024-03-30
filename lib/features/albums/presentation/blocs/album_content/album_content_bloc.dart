import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/albums/domain/entities/album_entity.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_albums_use_case.dart';

part 'album_content_bloc.freezed.dart';

part 'album_content_event.dart';

part 'album_content_state.dart';

class AlbumContentBloc extends Bloc<AlbumContentEvent, AlbumContentState> {
  AlbumContentBloc() : super(AlbumContentState.initial()) {
    on<_GetAlbumEvent>(_onGetAlbum);
  }

  final FetchAlbumsUseCase _fetchAlbumsUseCase = const FetchAlbumsUseCase();

  Future<void> _onGetAlbum(
    _GetAlbumEvent event,
    Emitter<AlbumContentState> emit,
  ) async {
    emit(AlbumContentState.loading());

    Result<List<AlbumEntity>> albumsResponse = await _fetchAlbumsUseCase.execute(
      FetchAlbumsParams(
        albumId: event.albumId,
      ),
    );

    albumsResponse.when(
      failure: (Failure failure) => emit(AlbumContentState.failure(failure)),
      success: (List<AlbumEntity> albums) => emit(AlbumContentState.success(subAlbums: albums)),
    );
  }
}
