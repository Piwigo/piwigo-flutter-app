import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_album_images_use_case.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_entity.dart';

part 'album_images_bloc.freezed.dart';

part 'album_images_event.dart';

part 'album_images_state.dart';

class AlbumImagesBloc extends Bloc<AlbumImagesEvent, AlbumImagesState> {
  AlbumImagesBloc() : super(AlbumImagesState.initial()) {
    on<_FetchAlbumImagesEvent>(_onFetchAlbumImages);
  }

  final FetchAlbumImagesUseCase _fetchAlbumImagesUseCase = const FetchAlbumImagesUseCase();

  Future<void> _onFetchAlbumImages(
    _FetchAlbumImagesEvent event,
    Emitter<AlbumImagesState> emit,
  ) async {
    emit(AlbumImagesState.loading());

    Result<List<ImageEntity>> response = await _fetchAlbumImagesUseCase.execute(
      FetchAlbumImagesParams(
        albumId: event.albumId,
      ),
    );

    response.when(
      failure: (Failure failure) => emit(AlbumImagesState.failure(failure)),
      success: (List<ImageEntity> images) => emit(AlbumImagesState.success(images: images)),
    );
  }
}
