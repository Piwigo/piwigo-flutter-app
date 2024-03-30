import 'package:piwigo_ng/core/utils/constants/settings_constants.dart';
import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/albums/data/repositories/album_repository.impl.dart';
import 'package:piwigo_ng/features/albums/domain/entities/album_entity.dart';
import 'package:piwigo_ng/features/albums/domain/repositories/album_repository.dart';
import 'package:piwigo_ng/features/images/data/enums/image_size_enum.dart';

class FetchAlbumsUseCase {
  const FetchAlbumsUseCase();

  final AlbumRepository _repository = const AlbumRepositoryImpl();

  Future<Result<List<AlbumEntity>>> execute(FetchAlbumsParams params) async => await _repository.fetchAlbums(params);
}

class FetchAlbumsParams {
  const FetchAlbumsParams({
    required this.albumId,
    this.thumbnailSize = SettingsConstants.defaultAlbumThumbnailSize,
  });

  final int albumId;
  final ImageSizeEnum thumbnailSize;
}
