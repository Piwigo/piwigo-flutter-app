import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime_type/mime_type.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/views/image/video_view.dart';

/// Media Full Screen page
/// * Video player
/// * Zoomable photos
class ImageViewPage extends StatefulWidget {
  const ImageViewPage({
    Key? key,
    this.imageList = const [],
    this.startId,
    this.album,
  }) : super(key: key);

  static const String routeName = '/image';

  final List<ImageModel> imageList;
  final int? startId;
  final AlbumModel? album;

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  final Duration _overlayAnimationDuration = const Duration(milliseconds: 300);
  final Curve _overlayAnimationCurve = Curves.ease;
  late final PageController _pageController;
  bool _showOverlay = true;
  int _page = 0;

  @override
  void initState() {
    final ImageModel? startImage = widget.imageList.firstWhere((image) => image.id == widget.startId);
    if (startImage != null) {
      _page = widget.imageList.indexOf(startImage);
    }
    _pageController = PageController(initialPage: _page);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
  void _onToggleOverlay(Orientation orientation) {
    // if (_showOverlay) {
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // } else {
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [
    //     if (orientation == Orientation.portrait) SystemUiOverlay.top,
    //   ]);
    // }
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  /// Edit current image action.
  void _onEdit() {}

  /// Move current image action.
  void _onMove() {}

  /// Delete current image action.
  void _onDelete() {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        // Changes System overlay colors to match black background
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
                  // Show bottom on portrait mode only
                  // (to keep vertical space in landscape mode).
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
                    '${widget.imageList[_page].name}',
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
                  IconButton(
                    onPressed: _onMove,
                    icon: Icon(Icons.drive_file_move),
                  ),
                  IconButton(
                    onPressed: _onDelete,
                    icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
                  ),
                ],
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert),
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
          // Compatibility with PageView and PhotoView
          pageController: _pageController,
          onPageChanged: (page) => setState(() {
            _page = page;
          }),
          itemCount: widget.imageList.length,
          builder: (context, index) {
            final ImageModel image = widget.imageList[index];
            // Check mime type of file (multiple test to ensure it is not null)
            String? mimeType = mime(image.file) ?? mime(image.elementUrl) ?? mime(image.derivatives.medium.url);
            if (mimeType != null && mimeType.startsWith('video')) {
              // Returns video player
              return PhotoViewGalleryPageOptions.customChild(
                disableGestures: true,
                child: VideoView(
                  videoUrl: image.elementUrl,
                  thumbnailUrl: image.derivatives.medium.url,
                  showOverlay: _showOverlay,
                  screenPadding: const EdgeInsets.only(bottom: 56.0),
                  onToggleOverlay: () => _onToggleOverlay(MediaQuery.of(context).orientation),
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
                return Center();
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
              children: [
                // Edit
                Expanded(
                  child: IconButton(
                    onPressed: _onEdit,
                    icon: Icon(Icons.edit),
                  ),
                ),
                // Move
                Expanded(
                  child: IconButton(
                    onPressed: _onMove,
                    icon: Icon(Icons.drive_file_move),
                  ),
                ),
                // Delete
                Expanded(
                  child: IconButton(
                    onPressed: _onDelete,
                    icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
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
