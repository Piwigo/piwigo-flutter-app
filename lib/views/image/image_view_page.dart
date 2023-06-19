import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:piwigo_ng/api/api_client.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/components/dialogs/image_comment_dialog.dart';
import 'package:piwigo_ng/components/popup_list_item.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/image_actions.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/resources.dart';
import 'package:piwigo_ng/views/image/video_player_page.dart';

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

  /// Server Cookie String
  String _serverCookie = '';

  /// Initialize [PageView]
  @override
  void initState() {
    _imageList = widget.images.sublist(0);
    _album = widget.album;
    final ImageModel? startImage =
        _imageList.firstWhere((image) => image.id == widget.startId);
    if (startImage != null) {
      _page = _imageList.indexOf(startImage);
      if (_imageList.last == startImage) {
        _loadMoreImages();
      }
    }
    _pageController = PageController(initialPage: _page);

    _loadCookies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getImagesInfo(_imageList);
    });
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
    ApiResult<List<ImageModel>> result =
        await fetchImages(_album.id, _imagePage + 1);
    if (result.hasError || !result.hasData) return;
    setState(() {
      _imagePage += 1;
      _imageList.addAll(result.data!);
    });
    _getImagesInfo(_imageList);
  }

  Future<void> _loadCookies() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    String? serverUrl = await secureStorage.read(key: 'SERVER_URL');
    List<Cookie> cookies =
        await ApiClient.cookieJar.loadForRequest(Uri.parse(serverUrl!));

    String cookiesStr =
        cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    setState(() {
      _serverCookie = cookiesStr;
    });
  }

  Future<void> _getImagesInfo(List<ImageModel> images) async {
    for (ImageModel image in images) {
      ApiResult<ImageModel>? result = await getImage(image.id);
      if (result.hasData) {
        int index = _imageList.indexWhere((i) => i.id == image.id);
        setState(() {
          _imageList[index] = result.data!;
        });
      }
    }
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
    ImageModel image = _currentImage;
    bool? success = await onEditPhotos(context, [image]);
    if (success == null || success == false) return;
    _getImagesInfo([image]);
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
            child: Stack(
              children: [
                _content,
                _top,
                _bottom,
              ],
            ),
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
                if (MediaQuery.of(context).orientation == Orientation.landscape)
                  ..._actions,
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
                            icon: !_currentImage.favorite
                                ? Icons.favorite_border
                                : Icons.favorite,
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

  /// Image tags
  Widget get _tags {
    List<TagModel> tags = _currentImage.tags;
    if (tags.isEmpty) return const SizedBox();
    return SizedBox(
      height: 36.0,
      child: Center(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          itemCount: tags.length,
          itemBuilder: (context, index) {
            TagModel tag = tags[index];
            return Text(
              "#${tag.name}",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.disabled,
                // color: AppColors.foregroundColors[colorIndex],
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8.0),
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
        child: Builder(builder: (context) {
          if (_serverCookie.isEmpty) return const SizedBox();
          return PhotoViewGallery.builder(
            // Compatibility with PageView and PhotoView
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

              String imageUrl = '';
              if (Preferences.getImageFullScreenSize == 'full') {
                imageUrl = image.elementUrl;
                imageUrl = HtmlUnescape().convert(imageUrl);
              } else {
                imageUrl = image
                        .getDerivativeFromString(
                            Preferences.getImageFullScreenSize)
                        ?.url ??
                    '';
              }

              ApiClient.cookieJar.loadForRequest(Uri.parse(imageUrl));

              // Check mime type of file (multiple test to ensure it is not null)
              if (image.isVideo) {
                // Returns video player
                return PhotoViewGalleryPageOptions.customChild(
                  disableGestures: true,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          image.derivatives.medium.url,
                          fit: BoxFit.contain,
                          errorBuilder: (context, o, s) {
                            debugPrint("$o\n$s");
                            return Center(
                              child: Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: IconButton(
                          color: Colors.white,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => Colors.black.withOpacity(0.5)),
                            shape: MaterialStateProperty.resolveWith(
                                (states) => CircleBorder()),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              VideoPlayerPage.routeName,
                              arguments: {
                                'videoUrl': image.elementUrl,
                                'thumbnailUrl': imageUrl,
                              },
                            );
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // child: VideoPlayerView(
                  //   videoUrl: image.elementUrl,
                  //   thumbnailUrl: image.derivatives.medium.url,
                  //   showOverlay: _showOverlay,
                  //   screenPadding: const EdgeInsets.only(bottom: 56.0),
                  //   onToggleOverlay: (value) => _onToggleOverlay(
                  //       MediaQuery.of(context).orientation, value),
                  // ),
                );
              }

              // Default behavior: Zoomable image
              return PhotoViewGalleryPageOptions(
                heroAttributes: PhotoViewHeroAttributes(
                  tag: image.id == _currentImage.id
                      ? "<hero image ${image.id}-${_album.id}>"
                      : "<no tag ${image.id}-${DateTime.now()}>",
                ),
                imageProvider: NetworkImage(
                  imageUrl,
                  headers: {HttpHeaders.cookieHeader: _serverCookie},
                ),
                maxScale: 2.0,
                minScale: PhotoViewComputedScale.contained,
                errorBuilder: (context, o, s) {
                  debugPrint("$o\n$s");
                  return SizedBox();
                },
              );
            },
          );
        }),
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
          child: OrientationBuilder(builder: (context, orientation) {
            return Column(
              children: [
                _comment,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: AnimatedSize(
                    duration: _overlayAnimationDuration,
                    curve: _overlayAnimationCurve,
                    child: _tags,
                  ),
                ),
                if (MediaQuery.of(context).orientation == Orientation.portrait)
                  Container(
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Row(
                      children: _actions
                          .map((action) => Expanded(child: action))
                          .toList(),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Description of the file
  Widget get _comment {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        constraints: BoxConstraints(maxHeight: 80),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: AnimatedSize(
          duration: _overlayAnimationDuration,
          curve: _overlayAnimationCurve,
          child: Builder(builder: (context) {
            if (_currentImage.comment == null || _currentImage.comment!.isEmpty)
              return const SizedBox();
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showDialog(
                  barrierColor: Colors.black.withOpacity(0.6),
                  context: context,
                  builder: (context) {
                    return ImageCommentDialog(image: _currentImage);
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Text(
                  _currentImage.comment?.replaceAll('\n', ' ') ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<Widget> get _actions {
    List<Widget> adminActions = [
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
        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
      ),
    ];
    List<Widget> userActions = [
      IconButton(
        onPressed: () => share([_currentImage]),
        icon: Icon(Icons.share),
      ),
      if (Preferences.getUserStatus != 'guest')
        IconButton(
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
      IconButton(
        onPressed: () => downloadImages([_currentImage]),
        icon: Icon(Icons.download),
      ),
    ];

    return widget.isAdmin ? adminActions : userActions;
  }
}
