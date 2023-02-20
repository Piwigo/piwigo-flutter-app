import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/components/popup_list_item.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/image_actions.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/image/video_view.dart';

/// Media Full Screen page
/// * Video player
/// * Zoomable photos
class ImageViewPage extends StatefulWidget {
  const ImageViewPage({
    Key? key,
    this.images = const [],
    this.startId,
    required this.album,
    this.isAdmin = false,
  }) : super(key: key);

  static const String routeName = '/image';

  final List<ImageModel> images;
  final int? startId;
  final AlbumModel album;
  final bool isAdmin;

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  /// Duration of overlay animation
  final Duration _overlayAnimationDuration = const Duration(milliseconds: 300);

  /// Curve of overlay animation
  final Curve _overlayAnimationCurve = Curves.ease;

  /// Controller of [PhotoViewGallery]
  late final PageController _pageController;

  /// Copy of album image list
  late List<ImageModel> _imageList;

  /// Copy of album image list
  late AlbumModel _album;

  /// Status of the overlay
  bool _showOverlay = true;

  /// Current page of [PhotoViewGallery]
  int _page = 0;

  /// API Image Pagination
  int _imagePage = 0;

  /// Initialize [PageView]
  @override
  void initState() {
    _imageList = widget.images.sublist(0);
    _album = widget.album;
    final ImageModel? startImage = _imageList.firstWhere((image) => image.id == widget.startId);
    if (startImage != null) {
      _page = _imageList.indexOf(startImage);
      if (_imageList.last == startImage) {
        _loadMoreImages();
      }
    }
    _pageController = PageController(initialPage: _page);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Load more images with API pagination
  /// Triggers when changing to last page
  Future<void> _loadMoreImages() async {
    if (_album.id == -1) return;
    if (_album.nbImages <= _imageList.length) return;
    ApiResult<List<ImageModel>> result = await fetchImages(_album.id, _imagePage + 1);
    if (result.hasError || !result.hasData) return;
    setState(() {
      _imagePage += 1;
      _imageList.addAll(result.data!);
    });
  }

  /// Get image that is shown in the [PhotoViewGallery] at [_page]
  ImageModel get _currentImage => _imageList[_page];

  /// Handler before closing the page.
  /// * If overlay is hidden, show it.
  /// * Otherwise, close the page.
  Future<bool> _onWillPop() async {
    if (!_showOverlay) {
      setState(() {
        _showOverlay = true;
      });
      return false;
    }
    return true;
  }

  /// Toggle overlay action (orientation was necessary, *see comments*).
  void _onToggleOverlay(Orientation orientation, [bool? value]) {
    // if (_showOverlay) {
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // } else {
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [
    //     if (orientation == Orientation.portrait) SystemUiOverlay.top,
    //   ]);
    // }
    setState(() {
      if (value != null) {
        _showOverlay = value;
      } else {
        _showOverlay = !_showOverlay;
      }
    });
  }

  /// Handle when
  Future<void> _onRemoveImage(ImageModel image) async {
    if (_imageList.length == 1) {
      Navigator.of(context).pop();
    }
    if (_imageList.length - 1 == _page) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
    setState(() {
      _imageList.remove(image);
      _album.nbImages -= 1;
      _album.nbTotalImages -= 1;
    });
  }

  /// Edit current image action.
  Future<void> _onEdit() async {
    bool? success = await onEditPhotos(context, [_currentImage]);
    if (success == null || success == false) return;
    ApiResult<ImageModel> result = await getImage(_currentImage.id);
    if (!result.hasData) return;
    setState(() {
      _imageList[_page] = result.data!;
    });
  }

  /// Move current image action.
  Future<void> _onMove() async {
    ImageModel image = _currentImage;
    int? success;
    if (_album.id == -1) {
      success = await onMovePhotos(context, [image]);
    } else {
      success = await onMovePhotos(context, [image], _album);
    }
    if (success == null || success != 0) return;
    _onRemoveImage(image);
  }

  /// Delete current image action.
  Future<void> _onDelete() async {
    ImageModel image = _currentImage;
    bool? success = await onDeletePhotos(context, [image], _album);
    if (!success) return;
    _onRemoveImage(image);
  }

  /// Add or remove current photo from favorites
  Future<void> _onLike() async {
    bool? result = await onLikePhotos([_currentImage], !_currentImage.favorite);
    if (result == null) return;
    setState(() {
      _currentImage.favorite = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        /// Changes System overlay colors to match black background
        value: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: Colors.black.withOpacity(0.1),
          statusBarColor: Colors.black.withOpacity(0.1),
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: true,
          extendBodyBehindAppBar: true,
          extendBody: true,
          primary: false,
          body: SafeArea(
            child: OrientationBuilder(builder: (context, orientation) {
              return Stack(
                children: [
                  _content,
                  _top,

                  /// Show bottom on portrait mode only
                  /// (to keep vertical space in landscape mode).
                  if (orientation == Orientation.portrait) _bottom,
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Overlay top section.
  ///
  /// Contains actions on current file (landscape):
  /// * Edit
  /// * Move
  /// * delete
  Widget get _top {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: AnimatedSlide(
        duration: _overlayAnimationDuration,
        curve: _overlayAnimationCurve,
        offset: _showOverlay ? Offset.zero : Offset(0, -1),
        child: AnimatedOpacity(
          duration: _overlayAnimationDuration,
          curve: _overlayAnimationCurve,
          opacity: _showOverlay ? 1 : 0,
          child: Container(
            height: 56.0,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    '${_currentImage.name}',
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                if (MediaQuery.of(context).orientation == Orientation.landscape) ...[
                  IconButton(
                    onPressed: _onEdit,
                    icon: Icon(Icons.edit),
                  ),
                  if (_album.id != -1)
                    IconButton(
                      onPressed: _onMove,
                      icon: Icon(Icons.drive_file_move),
                    ),
                  IconButton(
                    onPressed: _onDelete,
                    icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
                  ),
                ],
                if (widget.isAdmin)
                  PopupMenuButton(
                    position: PopupMenuPosition.under,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => Future.delayed(
                          const Duration(seconds: 0),
                          () => share([_currentImage]),
                        ),
                        child: PopupListItem(
                          icon: Icons.share,
                          text: appStrings.imageOptions_share,
                        ),
                      ),
                      if (Preferences.getUserStatus != 'guest')
                        PopupMenuItem(
                          onTap: () => Future.delayed(
                            const Duration(seconds: 0),
                            _onLike,
                          ),
                          child: PopupListItem(
                            icon: !_currentImage.favorite ? Icons.favorite_border : Icons.favorite,
                            text: !_currentImage.favorite
                                ? appStrings.imageOptions_addFavorites
                                : appStrings.imageOptions_removeFavorites,
                          ),
                        ),
                      PopupMenuItem(
                        onTap: () => Future.delayed(
                          const Duration(seconds: 0),
                          () => downloadImages([_currentImage]),
                        ),
                        child: PopupListItem(
                          icon: Icons.download,
                          text: appStrings.downloadImage_title(1),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Page content
  ///
  /// Show video or image
  Widget get _content {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onToggleOverlay(MediaQuery.of(context).orientation),
        child: PhotoViewGallery.builder(
          /// Compatibility with PageView and PhotoView
          pageController: _pageController,
          onPageChanged: (page) => setState(() {
            _page = page;
            if (page == _imageList.length - 1) {
              _loadMoreImages();
            }
          }),
          itemCount: _imageList.length,
          builder: (context, index) {
            final ImageModel image = _imageList[index];

            // Check mime type of file (multiple test to ensure it is not null)
            if (image.isVideo) {
              // Returns video player
              return PhotoViewGalleryPageOptions.customChild(
                disableGestures: true,
                child: VideoPlayerView(
                  videoUrl: image.elementUrl,
                  thumbnailUrl: image.derivatives.medium.url,
                  showOverlay: _showOverlay,
                  screenPadding: const EdgeInsets.only(bottom: 56.0),
                  onToggleOverlay: (value) => _onToggleOverlay(MediaQuery.of(context).orientation, value),
                ),
              );
            }

            // Default behavior: Zoomable image
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(
                image.getDerivativeFromString(Preferences.getImageFullScreenSize)?.url ?? '',
              ),
              maxScale: 2.0,
              minScale: PhotoViewComputedScale.contained,
              errorBuilder: (context, o, s) {
                debugPrint("$o");
                return SizedBox();
              },
            );
          },
        ),
      ),
    );
  }

  /// Overlay bottom section.
  ///
  /// Contains actions on current file (portrait):
  /// * Edit
  /// * Move
  /// * delete
  Widget get _bottom {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: AnimatedSlide(
        duration: _overlayAnimationDuration,
        curve: _overlayAnimationCurve,
        offset: _showOverlay ? Offset.zero : Offset(0, 1),
        child: AnimatedOpacity(
          duration: _overlayAnimationDuration,
          curve: _overlayAnimationCurve,
          opacity: _showOverlay ? 1 : 0,
          child: Container(
            height: 56.0,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Row(
              children: widget.isAdmin
                  ? [
                      Expanded(
                        child: IconButton(
                          onPressed: _onEdit,
                          icon: Icon(Icons.edit),
                        ),
                      ),
                      if (_album.id != -1)
                        Expanded(
                          child: IconButton(
                            onPressed: _onMove,
                            icon: Icon(Icons.drive_file_move),
                          ),
                        ),
                      Expanded(
                        child: IconButton(
                          onPressed: _onDelete,
                          icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
                        ),
                      ),
                    ]
                  : [
                      Expanded(
                        child: IconButton(
                          onPressed: () => share([_currentImage]),
                          icon: Icon(Icons.share),
                        ),
                      ),
                      if (Preferences.getUserStatus != 'guest')
                        Expanded(
                          child: IconButton(
                            onPressed: _onLike,
                            icon: Builder(
                              builder: (context) {
                                if (!_currentImage.favorite) {
                                  return Icon(Icons.favorite_border);
                                }
                                return Icon(Icons.favorite);
                              },
                            ),
                          ),
                        ),
                      Expanded(
                        child: IconButton(
                          onPressed: () => downloadImages([_currentImage]),
                          icon: Icon(Icons.download),
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
