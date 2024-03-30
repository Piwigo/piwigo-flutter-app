import 'package:piwigo_ng/core/enum/sort_method_enum.dart';
import 'package:piwigo_ng/core/utils/constants/settings_constants.dart';
import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/albums/data/repositories/album_repository.impl.dart';
import 'package:piwigo_ng/features/albums/domain/repositories/album_repository.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_entity.dart';

class FetchAlbumImagesUseCase {
  const FetchAlbumImagesUseCase();

  final AlbumRepository _repository = const AlbumRepositoryImpl();

  Future<Result<List<ImageEntity>>> execute(FetchAlbumImagesParams params) async =>
      await _repository.fetchAlbumImages(params);
}

class FetchAlbumImagesParams {
  const FetchAlbumImagesParams({
    required this.albumId,
    this.page = 0,
    this.count = SettingsConstants.defaultElementPerPage,
    this.sort = SettingsConstants.defaultImageSort,
  });

  final int albumId;
  final int page;
  final int count;
  final SortMethodEnum sort;
}
