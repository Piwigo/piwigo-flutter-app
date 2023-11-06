import 'package:piwigo_ng/utils/settings.dart';

enum ApiErrors {
  error,
  wrongLoginId,
  wrongServerUrl,
  fetchAlbumsError,
  fetchAlbumListError,
  fetchImagesError,
  fetchFavoritesError,
  searchImagesError,
  getStatusError,
  getInfoError,
  getMethodsError,
  createAlbumError,
  deleteAlbumError,
  editAlbumError,
  moveAlbumError,
}

class PagingModel {
  final int page;
  final int nbPerPage;
  final int nbTotal;

  PagingModel({
    this.page = 0,
    this.nbPerPage = Settings.defaultElementPerPage,
    this.nbTotal = 1,
  });

  PagingModel.fromJson({required Map<String, dynamic> json})
      : page = json['page'] ?? 0,
        nbPerPage = json['per_page'] ?? Settings.defaultElementPerPage,
        nbTotal = json['count'] ?? 1;
}

class ApiResponse<T> {
  final T? data;
  final ApiErrors? error;
  final PagingModel? paging;

  const ApiResponse({
    this.data,
    this.error,
    this.paging,
  }) : assert(data != null || error != null);

  bool get hasError => error != null;
  bool get hasData => data != null;
}
