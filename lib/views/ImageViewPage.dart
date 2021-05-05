import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


class ImageViewPage extends StatefulWidget {
  ImageViewPage({Key key, this.images, this.index, this.isAdmin}) : super(key: key);

  final int index;
  final List<dynamic> images;
  final bool isAdmin;

  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  String _derivative;
  PageController _pageController;
  int _page;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _pageController = PageController(initialPage: widget.index);
    _derivative = "medium";
    _page = widget.index;
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
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
        title: Text('${widget.images[_page]['name']}',
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
              _settingModalBottomSheet(context, widget.images[_pageController.page.toInt()]);
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
      body: Container(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: widget.images.length,
          pageController: _pageController,
          onPageChanged: (newPage) {
            setState(() {
              _page = newPage;
            });
          },
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(widget.images[index]["derivatives"][_derivative]["url"]),
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
      /*
      bottomNavigationBar: widget.isAdmin? BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload, color: _theme.iconTheme.color),
            label: "share",
            // TODO: Implement share image
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reply_outlined, color: _theme.iconTheme.color),
            label: "move",
            // TODO: implement move image
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file, color: _theme.iconTheme.color),
            label: "attach",
            // TODO: implement attach miniature
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_outline, color: _theme.errorColor),
            label: "delete",
            // TODO: implement delete image
          ),
        ],
        backgroundColor: _theme.scaffoldBackgroundColor,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 16,
        unselectedFontSize: 16,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
      ) : Text(""),
       */
    );


  }

  void _settingModalBottomSheet(context, dynamic image) async {
    //TODO: copy IOS edit page
    List<String> derivs = image["derivatives"].keys.toList();

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) => Container(
            padding: EdgeInsets.all(20),
            color: Colors.grey.shade200,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(5),
                  child: DropdownButton<String>(
                    value: _derivative,
                    style: const TextStyle(
                        color: Colors.orange, fontSize: 16),
                    underline: Container(
                      height: 2,
                      color: Colors.grey,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        _derivative = newValue;
                      });
                    },
                    items: derivs.map<DropdownMenuItem<String>>((
                        String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );

    setState(() {
      print("Changed size to $_derivative");
    });
  }
}