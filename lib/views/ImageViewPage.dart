import 'package:cached_network_image/cached_network_image.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/services/MoveAlbumService.dart';
import 'package:piwigo_ng/ui/Dialogs.dart';
import 'package:piwigo_ng/ui/SnackBars.dart';


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
  int _page;
  int _imagePage;
  List<dynamic> images = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _pageController = PageController(initialPage: widget.index);
    _derivative = "medium";
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
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> nextPage() async {
    _imagePage++;
    await images.addAll(await fetchImages(widget.category, _imagePage));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      primary: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: _theme.iconTheme.color, //change your color here
        ),
        centerTitle: true,
        title: Text('${images[_page]['name']}',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        backgroundColor: Color(0x80000000),
        actions: [/*
          widget.isAdmin? IconButton(
            onPressed: () {
              _settingModalBottomSheet(context, images[_pageController.page.toInt()]);
            },
            icon: Icon(Icons.edit),
          ) : IconButton(
            onPressed: () {
              //TODO: Implement share image
              print("share");
            },
            icon: Icon(Icons.share),
          ),
           Text(""),
           */
        ],
      ),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: images.length,
          pageController: _pageController,
          onPageChanged: (newPage) async {
            if(newPage == images.length-1) {
              await nextPage();
            }
            setState(() {
              _page = newPage;
            });
          },
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(images[index]["derivatives"][_derivative]["url"]),
              minScale: PhotoViewComputedScale.contained,
            );
          },
          loadingBuilder: (context, event) => Center(
            child: Container(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.isAdmin? BottomNavigationBar(
        onTap: (index) async {
          switch (index) {
            case 0:
              if(await confirm(context,
                title: Text('Confirm'),
                content: Text('Download ${images[_page]['name']} ?', softWrap: true, maxLines: 3),
                textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
              )) {
                print('Download $_page');

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Downloading ${images[_page]['name']}'),
                      CircularProgressIndicator(),
                    ],
                  ),
                ));

                await downloadSingleImage(images[_page]);
              }
              break;
            case 1:
              print('Move $_page');
              await moveCategoryModalBottomSheet(context,
                widget.category,
                widget.title,
                true,
                (item) async {
                  String result = await confirmMoveAssignImage(
                    context,
                    title: Text('Confirm'),
                    content: Text('Move ${images[_page]} to ${item.name} ?',
                        softWrap: true,
                        maxLines: 3
                    ),
                  );

                  if (result == 'move') {
                    print('Move $_page to ${item.id}');
                    await moveImage(images[_page]['id'], [int.parse(item.id)]);
                    ScaffoldMessenger.of(context).showSnackBar(
                        imageMovedSnackBar(images[_page]['name'], item.name));
                    Navigator.of(context).pop();
                  } else if (result == 'assign') {
                    print('Assign $_page to ${item.id}');
                    await copyImage(images[_page]['id'], [int.parse(item.id)]);
                    ScaffoldMessenger.of(context).showSnackBar(
                        imageAssignedSnackBar(images[_page]['name'], item.name));
                    Navigator.of(context).pop();
                  }
                },
              );
              break;
              /*
            case 2:
              print('Attach $_page');
              await moveCategoryModalBottomSheet(context,
                widget.category,
                widget.title,
                true,
                (item) async {
                  // TODO: implement Attach function
                },
              );
              break;
               */
            case 2: // TODO: change to 3 if implemented Attach function
              if(await confirm(context,
                title: Text('Confirm'),
                content: Text('Delete ${images[_page]['name']} ?', softWrap: true, maxLines: 3),
                textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
              )) {
                print('Delete $_page');

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Deleting ${images[_page]['name']}'),
                ));

                await deleteImage(images[_page]['id']);
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
              break;
            default:
              break;
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded, color: _theme.iconTheme.color),
            label: "Download",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reply_outlined, color: _theme.iconTheme.color),
            label: "Move",
          ),
          /*
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file, color: _theme.iconTheme.color),
            label: "Attach",
            // TODO: implement attach miniature
          ),
          */
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_outline, color: _theme.errorColor),
            label: "Delete",
          ),
        ],
        backgroundColor: Color(0x80000000),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: _theme.primaryColorLight,
        unselectedItemColor: _theme.primaryColorLight,
      ) : Text(""),
    );
  }
}