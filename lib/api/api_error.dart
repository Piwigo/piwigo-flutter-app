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

class ApiResult<T> {
  T? data;
  ApiErrors? error;

  ApiResult({this.data, this.error}) : assert(data != null || error != null);

  bool get hasError => error != null;
  bool get hasData => data != null;
}
