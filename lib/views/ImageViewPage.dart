import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:photo_view/photo_view.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';
import 'package:path/path.dart' as Path;

import 'package:piwigo_ng/views/VideoPlayerViewPage.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';


class ImageViewPage extends StatefulWidget {
  ImageViewPage({Key key, this.images, this.index = 0, this.isAdmin = false, this.category = "0", this.title = "Album", this.page = 0}) : super(key: key);

  final int index;
  final List<dynamic> images;
  final bool isAdmin;
  final String category;
  final String title;
  final int page;

  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}
class _ImageViewPageState extends State<ImageViewPage> {
  String _derivative;
  PageController _pageController;
  ScrollPhysics _pageViewPhysic = BouncingScrollPhysics();
  int _page;
  int _imagePage;
  List<dynamic> images = [];
  bool showToolBar = true;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: [SystemUiOverlay.bottom]);
    _pageController = PageController(initialPage: widget.index);
    _derivative = API.prefs.getString('full_screen_image_size');
    _page = widget.index;
    _imagePage = (widget.images.length/100).ceil()-1;
    images.addAll(widget.images);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(widget.index == images.length-1) {
        await nextPage();
        setState(() {
          print(images.length);
        });
      }
    });
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> nextPage() async {
    _imagePage++;
    var response = await fetchImages(widget.category, _imagePage);
    if(response['stat'] == 'fail') {
      ScaffoldMessenger.of(context).showSnackBar(
          errorSnackBar(context, response['result'])
      );
    } else {
      images.addAll(response['result']['images']);
    }
  }

  void _onEditImage() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditImagesPage(
        catId: int.parse(widget.category),
        images: [images[_page]],
      ))
    );
  }
  void _onDownloadImage() async {
    if(await confirmDownloadDialog(context,
      content: appStrings(context).downloadImage_confirmation(1),
    )) {
      print('Download $_page');

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(appStrings(context).downloadingImages(1)),
            CircularProgressIndicator(),
          ],
        ),
      ));
      await downloadSingleImage(images[_page]);
    }
  }
  void _onMoveCopyImage() async {
    int choice = await chooseMoveCopyImage(context);

    switch(choice) {
      case 0: showDialog(context: context,
          builder: (context) {
            return MoveOrCopyDialog(
              title: appStrings(context).moveImage_title,
              subtitle: appStrings(context).moveImage_selectAlbum(1, images[_page]['name']),
              catId: widget.category,
              catName: widget.title,
              isImage: true,
              onSelected: (item) async {
                if(await confirmMoveDialog(context,
                  content: appStrings(context).moveImage_message(1, images[_page]['name'], item.name),
                )) {
                  var response = await moveImage(images[_page]['id'], [int.parse(item.id)]);
                  if(response['stat'] == 'fail') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        errorSnackBar(context, response['result']));
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        imagesMovedSnackBar(context, 1));
                    Navigator.of(context).pop();
                  }
                }
              },
            );
          }
      ).whenComplete(() {
        setState(() {});
      });
      break;
      case 1: showDialog(context: context,
          builder: (context) {
            return MoveOrCopyDialog(
              title: appStrings(context).copyImage_title,
              subtitle: appStrings(context).copyImage_selectAlbum(1, images[_page]['name']),
              catId: widget.category,
              catName: widget.title,
              isImage: true,
              onSelected: (item) async {
                if(await confirmAssignDialog(context,
                  content: appStrings(context).copyImage_message(1, images[_page]['name'], item.name),
                )) {
                  var response = await assignImage(images[_page]['id'], [int.parse(item.id)]);
                  if (response['stat'] == 'fail') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        errorSnackBar(context, response['result']));
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        imagesAssignedSnackBar(context, 1));
                    Navigator.of(context).pop();
                  }
                }
              },
            );
          }
      ).whenComplete(() {
        setState(() {});
      });
      break;
      default: break;
    }
  }
  void _onDeleteImage() async {
    if(await confirmDeleteDialog(context,
      content: appStrings(context).deleteImage_message(1),
    )) {
      var response = await deleteImage(images[_page]['id']);
      if(response['stat'] == 'fail') {
        ScaffoldMessenger.of(context).showSnackBar(
            errorSnackBar(context, '${response['result']}')
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(appStrings(context).deleteImageHUD_deleting(1)),
        ));
      }
      int page = _page;
      if(page == images.length-1) {
        if (page == 0) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _page--;
            _pageController.previousPage(
                duration: Duration(milliseconds: 100),
                curve: Curves.easeIn);
          });
        }
      }
      images.removeAt(page);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      backgroundColor: showToolBar ?
        Theme.of(context).scaffoldBackgroundColor :
        Colors.black,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: showToolBar ? AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color, //change your color here
        ),
        centerTitle: true,
        title: Text('${images[_page]['name']}',
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ) : AppBar(
        elevation: 0,
        leading: SizedBox(),
        backgroundColor: Colors.transparent
      ),
      body: Container(
        child: GestureDetector(
          onTap: () {
            print('tap');
            setState(() {
              showToolBar = !showToolBar;
            });
          },
          child: PageView.builder(
            physics: _pageViewPhysic,
            itemCount: images.length,
            controller: _pageController,
            onPageChanged: (newPage) async {
              if(newPage == images.length-1) {
                await nextPage();
              }
              setState(() {
                _page = newPage;
                // showToolBar = true;
              });
            },
            itemBuilder: (context, index) {
              var image = images[index];
              if(Path.extension(image['element_url']) == '.mp4') {
                return _displayVideo(image);
              }
              return _displayImage(image);
            }
          ),
        ),
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _displayVideo(dynamic image) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: image["derivatives"][_derivative]["url"],
            fit: BoxFit.contain,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VideoPlayerViewPage(image['element_url'],
                ratio:image['width']/image['height'],
              ),
            ));
          },
          child: IconShadowWidget(
            Icon(Icons.play_arrow_rounded, size: 100, color: Color(0x80FFFFFF)),
            shadowColor: Colors.black45,
          ),
        ),
      ],
    );
  }

  Widget _displayImage(dynamic image) {
    return PhotoView(
      imageProvider: NetworkImage(image["derivatives"][_derivative]["url"]),
      minScale: PhotoViewComputedScale.contained,
      backgroundDecoration: BoxDecoration(
        color: showToolBar ?
        Theme.of(context).scaffoldBackgroundColor :
        Colors.black,
      ),
      scaleStateChangedCallback: (scale) {
        if(scale.isScaleStateZooming) {
          setState(() {
            _pageViewPhysic = NeverScrollableScrollPhysics();
          });
        } else {
          setState(() {
            _pageViewPhysic = BouncingScrollPhysics();
          });
        }
      },
    );
  }

  Widget _bottomNavigationBar() {
    return widget.isAdmin && showToolBar? BottomNavigationBar(
      onTap: (index) async {
        switch (index) {
          case 0:
            _onEditImage();
            break;
          case 1:
            _onDownloadImage();
            break;
          case 2:
            _onMoveCopyImage();
            break;
          case 3:
            _onDeleteImage();
            break;
          default:
            break;
        }
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
          label: appStrings(context).imageOptions_edit,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download_rounded, color: Theme.of(context).iconTheme.color),
          label: appStrings(context).imageOptions_download,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.reply_outlined, color: Theme.of(context).iconTheme.color),
          label: appStrings(context).moveImage_title,
        ),
        /*
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file, color: Theme.of(context).iconTheme.color),
            label: "Attach",
            // TODO: implement attach thumbnail
          ),
          */
        BottomNavigationBarItem(
          icon: Icon(Icons.delete_outline, color: Theme.of(context).errorColor),
          label: appStrings(context).deleteImage_delete,
        ),
      ],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 14,
      unselectedFontSize: 14,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Theme.of(context).primaryColorLight,
      unselectedItemColor: Theme.of(context).primaryColorLight,
    ) : SizedBox();
  }
}
