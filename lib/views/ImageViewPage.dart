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
import 'package:sliding_up_panel/sliding_up_panel.dart';


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
class _ImageViewPageState extends State<ImageViewPage> with SingleTickerProviderStateMixin {
  String _derivative;
  PageController _pageController;
  ScrollPhysics _pageViewPhysic = BouncingScrollPhysics();
  int _page;
  int _imagePage;
  List<dynamic> _images = [];
  bool _showToolBar = true;
  double _slideOffset = 0.0;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: [SystemUiOverlay.bottom]);
    _pageController = PageController(initialPage: widget.index);
    _derivative = API.prefs.getString('full_screen_image_size');
    _page = widget.index;
    _imagePage = (widget.images.length/100).ceil()-1;
    _images.addAll(widget.images);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(widget.index == _images.length-1) {
        await nextPage();
        setState(() {});
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
      _images.addAll(response['result']['images']);
    }
  }

  void _onEditImage() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditImagesPage(
        catId: int.parse(widget.category),
        images: [_images[_page]],
      ))
    );
  }
  void _onDownloadImage() async {
    if(await confirmDownloadDialog(context,
      content: appStrings(context).downloadImage_confirmation(1),
    )) {
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
      await downloadSingleImage(_images[_page]);
    }
  }
  void _onMoveCopyImage() async {
    int choice = await chooseMoveCopyImage(context);

    switch(choice) {
      case 0: showDialog(context: context,
          builder: (context) {
            return MoveOrCopyDialog(
              title: appStrings(context).moveImage_title,
              subtitle: appStrings(context).moveImage_selectAlbum(1, _images[_page]['name']),
              catId: widget.category,
              catName: widget.title,
              isImage: true,
              onSelected: (item) async {
                if(await confirmMoveDialog(context,
                  content: appStrings(context).moveImage_message(1, _images[_page]['name'], item.name),
                )) {
                  var response = await moveImage(_images[_page]['id'], [int.parse(item.id)]);
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
              subtitle: appStrings(context).copyImage_selectAlbum(1, _images[_page]['name']),
              catId: widget.category,
              catName: widget.title,
              isImage: true,
              onSelected: (item) async {
                if(await confirmAssignDialog(context,
                  content: appStrings(context).copyImage_message(1, _images[_page]['name'], item.name),
                )) {
                  var response = await assignImage(_images[_page]['id'], [int.parse(item.id)]);
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
    int choice = await confirmRemoveImagesFromAlbumDialog(context,
      content: appStrings(context).deleteImage_message(1),
      count: 1,
    );

    if(choice != -1) {
      switch(choice) {
        case 0:
          var response = await deleteImage(_images[_page]['id']);
          if(response['stat'] == 'fail') {
            ScaffoldMessenger.of(context).showSnackBar(
                errorSnackBar(context, '${response['result']}')
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(appStrings(context).deleteImageHUD_deleting(1)),
            ));
          }
          break;
        case 1:
          var response = await removeImage(_images[_page]['id'], widget.category);
          if(response['stat'] == 'fail') {
            ScaffoldMessenger.of(context).showSnackBar(
                errorSnackBar(context, '${response['result']}')
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(appStrings(context).removeImageHUD_removing(1)),
            ));
          }
          break;
        default: break;
      }

      int page = _page;
      if(page == _images.length-1) {
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
      _images.removeAt(page);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      extendBody: true,
      backgroundColor: _showToolBar ?
        Theme.of(context).scaffoldBackgroundColor :
        Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color, //change your color here
        ),
        centerTitle: true,
        title: Text('${_images[_page]['name'] ?? ""}',
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        backgroundColor: _showToolBar ? Theme.of(context).scaffoldBackgroundColor : Colors.black,
        toolbarHeight: _showToolBar ? kToolbarHeight : 0,
        actions: MediaQuery.of(context).orientation == Orientation.landscape ? [
          IconButton(
            onPressed: _onEditImage,
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _onDownloadImage,
            icon: Icon(Icons.download),
          ),
          IconButton(
            onPressed: _onMoveCopyImage,
            icon: Icon(Icons.reply),
          ),
          IconButton(
            onPressed: _onDeleteImage,
            icon: Icon(Icons.delete, color: Theme.of(context).errorColor,),
          ),
        ] : [],
      ),
      body: GestureDetector(
        onTap: () => setState(() {
          if(_slideOffset == 0.0) {
            _showToolBar = !_showToolBar;
          }
        }),
        child: PageView.builder(
            physics: _pageViewPhysic,
            itemCount: _images.length,
            controller: _pageController,
            onPageChanged: (newPage) async {
              if(newPage == _images.length-1) {
                await nextPage();
              }
              setState(() {
                _page = newPage;
              });
            },
            itemBuilder: (context, index) {
              var image = _images[index];
              print(image);
              return LayoutBuilder(
                builder: (context, constraints) {
                  double panelHeight = 0.0;
                  if(_showToolBar && widget.isAdmin) {
                    if(MediaQuery.of(context).orientation == Orientation.portrait) {
                      panelHeight = kBottomNavigationBarHeight + 40.0;
                    }
                  }
                  return SlidingUpPanel(
                    minHeight: panelHeight,
                    maxHeight: constraints.maxHeight,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.0 * (1 - _slideOffset)),
                    ),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    onPanelSlide: (slide) => setState(() {
                      _slideOffset = slide;
                    }),
                    panel: Column(
                      children: [
                        SizedBox(
                          height: kToolbarHeight,
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: Colors.grey.shade600
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox.square(
                                      dimension: MediaQuery.of(context).size.width/3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Image.network(image["derivatives"][_derivative]["url"],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                          padding: const EdgeInsets.all(5.0),
                                          height: MediaQuery.of(context).size.width/3-30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.horizontal(right: Radius.circular(10.0)),
                                            color: Theme.of(context).inputDecorationTheme.fillColor,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(image['file'], softWrap: true,),
                                              Text('${image['width']}x${image['height']} pixels'),
                                              Text(image['date_available']),
                                            ],
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(image['name'], style: TextStyle(
                                    fontSize: 20,
                                  ), softWrap: true,),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  color: Theme.of(context).cardColor,
                                  child: Column(
                                    children: [
                                      imageInfoRow(
                                        title: appStrings(context).editImageDetails_author,
                                        content: image['author'] ?? ''
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(appStrings(context).editImageDetails_author,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Expanded(
                                            child: Text(image['comment'] ?? "no description",
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(appStrings(context).editImageDetails_author),
                                          Expanded(
                                            child: Text(image['comment'] ?? "no description",
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(appStrings(context).editImageDetails_author),
                                          Expanded(
                                            child: Text(image['comment'] ?? "no description",
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(appStrings(context).editImageDetails_author),
                                          Expanded(
                                            child: Text(image['comment'] ?? "no description",
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    body: Builder(
                      builder: (context) {
                        if(Path.extension(image['element_url']) == '.mp4') {
                          return _displayVideo(image);
                        }
                        return _displayImage(image);
                      },
                    ),
                  );
                },
              );
            }
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
        color: _showToolBar ?
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
    if(MediaQuery.of(context).orientation == Orientation.portrait
        && widget.isAdmin && _showToolBar) {
      return BottomAppBar(
        elevation: 0.0,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _onEditImage,
              icon: Icon(Icons.edit),
            ),
            IconButton(
              onPressed: _onDownloadImage,
              icon: Icon(Icons.download),
            ),
            IconButton(
              onPressed: _onMoveCopyImage,
              icon: Icon(Icons.reply),
            ),
            IconButton(
              onPressed: _onDeleteImage,
              icon: Icon(Icons.delete, color: Theme.of(context).errorColor,),
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }

  Widget imageInfoRow({String title = '', String content = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
          style: TextStyle(fontSize: 16),
        ),
        Expanded(
          child: Text(content,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
