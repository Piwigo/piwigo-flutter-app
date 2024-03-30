import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/albums/domain/entities/album_entity.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_album_images_use_case.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_albums_use_case.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_entity.dart';

abstract class AlbumRepository {
  const AlbumRepository();

  Future<Result<List<AlbumEntity>>> fetchAlbums(FetchAlbumsParams params);

  Future<Result<List<ImageEntity>>> fetchAlbumImages(FetchAlbumImagesParams params);
}
