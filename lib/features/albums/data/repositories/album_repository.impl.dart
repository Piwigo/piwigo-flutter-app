import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/albums/data/datasources/album_datasource.dart';
import 'package:piwigo_ng/features/albums/data/datasources/album_datasource.impl.dart';
import 'package:piwigo_ng/features/albums/domain/entities/album_entity.dart';
import 'package:piwigo_ng/features/albums/domain/repositories/album_repository.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_album_images_use_case.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_albums_use_case.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_entity.dart';

class AlbumRepositoryImpl extends AlbumRepository {
  const AlbumRepositoryImpl();

  final AlbumDatasource _datasource = const AlbumDatasourceImpl();

  @override
  Future<Result<List<AlbumEntity>>> fetchAlbums(FetchAlbumsParams params) => _datasource.fetchAlbums(params);

  @override
  Future<Result<List<ImageEntity>>> fetchAlbumImages(FetchAlbumImagesParams params) =>
      _datasource.fetchAlbumImages(params);
}
