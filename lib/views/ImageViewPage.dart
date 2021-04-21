import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


class ImageViewPage extends StatefulWidget {
  ImageViewPage({Key key, this.images, this.index}) : super(key: key);

  final int index;
  final List<dynamic> images;

  @override
  _ImageViewPageState createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  String _derivative;
  PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
    _derivative = "medium";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.orange, //change your color here
        ),
        backgroundColor: Colors.grey.shade200,
        actions: [
          Container(
            padding: EdgeInsets.all(15),
            child: IconButton(
              onPressed: () {
                _settingModalBottomSheet(context, widget.images[_pageController.page.toInt()]);
              },
              icon: Icon(Icons.edit),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: widget.images.length,
          pageController: _pageController,
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
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload, color: Colors.orange),
            label: "upload",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reply_outlined, color: Colors.orange),
            label: "share",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file, color: Colors.orange),
            label: "attach",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            label: "delete",
          ),
        ],
        backgroundColor: Colors.grey.shade200,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 16,
        unselectedFontSize: 16,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
      ),
    );


  }

  void _settingModalBottomSheet(context, dynamic image) async {

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