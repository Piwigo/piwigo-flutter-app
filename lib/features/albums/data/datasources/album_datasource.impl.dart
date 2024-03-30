import 'package:piwigo_ng/core/data/datasources/remote/remote_datasource.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/utils/constants/api_constants.dart';
import 'package:piwigo_ng/core/utils/result.dart';
import 'package:piwigo_ng/features/albums/data/datasources/album_datasource.dart';
import 'package:piwigo_ng/features/albums/data/models/album_model.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_album_images_use_case.dart';
import 'package:piwigo_ng/features/albums/domain/usecases/fetch_albums_use_case.dart';
import 'package:piwigo_ng/features/images/data/models/image_model.dart';

class AlbumDatasourceImpl extends AlbumDatasource {
  const AlbumDatasourceImpl();

  final RemoteDatasource _remote = const RemoteDatasource();

  @override
  Future<Result<List<AlbumModel>>> fetchAlbums(FetchAlbumsParams params) async {
    final Map<String, dynamic> queries = <String, dynamic>{
      'cat_id': params.albumId,
      'thumbnail_size': params.thumbnailSize.value,
    };

    Result<Map<String, dynamic>> response = await _remote.get<Map<String, dynamic>>(
      method: ApiConstants.getAlbumsMethod,
      queryParameters: queries,
    );

    return response.when(
      failure: (Failure failure) => Result<List<AlbumModel>>.failure(failure),
      success: (Map<String, dynamic> data) {
        List<AlbumModel> albums = data['categories']
            .map<AlbumModel>(
              (dynamic album) => AlbumModel.fromJson(album),
            )
            .where((AlbumModel album) => album.id != params.albumId) // remove current album
            .toList();
        return Result<List<AlbumModel>>.success(albums);
      },
    );
  }

  @override
  Future<Result<List<ImageModel>>> fetchAlbumImages(FetchAlbumImagesParams params) async {
    Map<String, dynamic> queries = <String, dynamic>{
      'cat_id': params.albumId,
      'order': params.sort.value,
      'per_page': params.count,
      'page': params.page,
    };

    Result<Map<String, dynamic>> response = await _remote.get<Map<String, dynamic>>(
      method: ApiConstants.getAlbumImagesMethod,
      queryParameters: queries,
    );

    return response.when(
      failure: (Failure failure) => Result<List<ImageModel>>.failure(failure),
      success: (Map<String, dynamic> data) {
        List<ImageModel> images = data['images']
            .map<ImageModel>(
              (dynamic image) => ImageModel.fromJson(image),
            )
            .toList();
        return Result<List<ImageModel>>.success(images);
      },
    );
  }
}
