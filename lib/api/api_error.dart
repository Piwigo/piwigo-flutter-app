enum ApiErrors {
  wrongLoginId,
  wrongServerUrl,
  fetchAlbumsError,
  fetchAlbumListError,
  fetchImagesError,
  getStatusError,
}

class ApiResult<T> {
  T? data;
  ApiErrors? error;

  ApiResult({this.data, this.error}) : assert(data != null || error != null);

  bool get hasError => error != null;
  bool get hasData => data != null;
}
