part of 'app_router.dart';

@Freezed(copyWith: false, fromJson: false, toJson: false)
class PageRouteArguments with _$PageRouteArguments {
  const factory PageRouteArguments.album({required AlbumEntity album}) = _AlbumPageArgs;
}
