import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/albums/data/models/album_model.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_album_images_use_case.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_albums_use_case.dart';
import 'package:piwigo_ng/features/images/data/models/image_model.dart';

abstract class AlbumDatasource {
  const AlbumDatasource();

  Future<Result<List<AlbumModel>>> fetchAlbums(FetchAlbumsParams params);

  Future<Result<List<ImageModel>>> fetchAlbumImages(FetchAlbumImagesParams params);
}
