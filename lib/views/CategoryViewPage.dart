import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'dart:convert';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/services/MoveAlbumService.dart';
import 'package:piwigo_ng/ui/Dialogs.dart';
import 'package:piwigo_ng/ui/ListItems.dart';
import 'package:piwigo_ng/ui/SnackBars.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ImageViewPage.dart';
import 'UploadGalleryViewPage.dart';



class CategoryViewPage extends StatefulWidget {
  CategoryViewPage({Key key, this.title, this.category, this.isAdmin, this.nbImages}) : super(key: key);
  final bool isAdmin;
  final String title;
  final String category;
  final int nbImages;

  @override
  _CategoryViewPageState createState() => _CategoryViewPageState();
}

class _CategoryViewPageState extends State<CategoryViewPage> with SingleTickerProviderStateMixin {
  bool _isEditMode;
  int _page;
  int _nbImages;
  Map<int, bool> _selectedItems = Map();
  ScrollController _controller = ScrollController();
  List<dynamic> imageList = [];


  @override
  void initState() {
    super.initState();
    _page = 0;
    _nbImages = widget.nbImages;
    _isEditMode = false;
  }

  showMore() async {
    _page++;
    var newListPage = await fetchImages(widget.category, _page);
    print('Fetch images of page $_page');
    setState(() {
      imageList.addAll(newListPage);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> fetchImages(String albumID, int page) async {
    Map<String, String> queries = {
      "format":"json",
      "method": "pwg.categories.getImages",
      "cat_id": albumID,
      "per_page": "100",
      "page": page.toString(),
    };

    Response response = await API.dio.get('ws.php', queryParameters: queries);

    if (response.statusCode == 200) {
      return json.decode(response.data)["result"]["images"];
    } else {
      throw Exception("bad request: "+response.statusCode.toString());
    }
  }

  bool _isSelected(int index) {
    return _selectedItems[index] == null ? false : _selectedItems[index];
  }
  int _selectedPhotos() {
    int n = 0;
    _selectedItems.forEach((key, value) {if(value) n++;});
    return n;
  }
  String albumSubCount(dynamic album) {
    String displayString = '${album["total_nb_images"]} ${album["total_nb_images"] == 1 ? 'photo' : 'photos'}';
    if(album["nb_categories"] > 0) {
      displayString += ', ${album["nb_categories"]} ${album["nb_categories"] == 1 ? 'sub-album' : 'sub-albums'}';
    }
    return displayString;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: NestedScrollView(
        controller: _controller,
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            centerTitle: true,
            // expandedHeight: 100.0,
            iconTheme: IconThemeData(
              color: _theme.iconTheme.color,//change your color here
            ),
            leading: _isEditMode ? IconButton(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                });
                _selectedItems.forEach((key, value) {
                  setState(() {
                    _selectedItems[key] = false;
                  });
                });
              },
              icon: Icon(Icons.cancel),
            ) : IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.chevron_left),
            ),
            title: _isEditMode ?
              Text("${_selectedPhotos()}", overflow: TextOverflow.fade, softWrap: true) :
              Text(widget.title),
            // TODO: Implement selection actions
            /*
            actions: [
              _isEditMode ? IconButton(
                onPressed: () {
                  List<int> selection = [];
                  _selectedItems.forEach((key, value) {
                    if(value) selection.add(key);
                  });
                  print('Selected: $selection');
                },
                icon: Icon(Icons.edit),
              ) : widget.isAdmin? IconButton(
                onPressed: () {
                  setState(() {
                    _isEditMode = true;
                  });
                },
                icon: Icon(Icons.touch_app),
              ) : Container(),
            ],
             */
          ),
        ],
        body: FutureBuilder<List<dynamic>>(
          future: fetchAlbums(widget.category), // Albums of the list
          builder: (BuildContext context, AsyncSnapshot albums) {
            if (albums.hasData) {
              int nbImages = _nbImages;
              if(albums.data.length > 0 && albums.data[0]["id"].toString() == widget.category) {
                nbImages = albums.data[0]["total_nb_images"];
                _nbImages = nbImages;
              }
              albums.data.removeWhere((category) =>
                (category["id"].toString() == widget.category)
              );
              return FutureBuilder<List<dynamic>>(
                  future: fetchImages(widget.category, 0), // Images of the list
                  builder: (BuildContext context, AsyncSnapshot images) {
                    if (images.hasData) {
                      if (imageList.isEmpty || _page == 0) {
                        imageList.clear();
                        imageList.addAll(images.data);
                      }
                      return RefreshIndicator(
                        displacement: 20,
                        onRefresh: () {
                          setState(() {
                            _page = 0;
                          });
                          return Future.delayed(Duration(milliseconds: 500));
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                itemCount: albums.data.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return albumListItem(context, albums.data[index], widget.isAdmin, (message) {
                                    setState(() {
                                      print('$message');
                                    });
                                  });
                                },
                              ),
                              GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 3.0,
                                  crossAxisSpacing: 3.0,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                itemCount: imageList.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  if(_selectedItems.isEmpty) {
                                    imageList.forEach((item) {
                                      _selectedItems[index] = false;
                                    });
                                  }
                                  return InkWell(
                                    onTap: () {
                                      _isEditMode ?
                                      setState(() {
                                        _isSelected(index) ?
                                        _selectedItems[index] = false :
                                        _selectedItems[index] = true;
                                      }) :
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => ImageViewPage(
                                          images: imageList,
                                          index: index,
                                          isAdmin: widget.isAdmin,
                                        )),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                          image: Image.network(imageList[index]["derivatives"][API.prefs.getString('miniature_size')]["url"]).image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: _isEditMode? Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: _isSelected(index) ?
                                          Icon(Icons.check_circle, color: Colors.orange) :
                                          Icon(Icons.check_circle_outline, color: Colors.grey),
                                        ),
                                      ) : Text(""),
                                    ),
                                  );
                                },
                              ),
                              nbImages > (_page+1)*100 ? GestureDetector(
                                onTap: () {
                                  showMore();
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Show ${nbImages-(_page+1*100)} more ...', style: TextStyle(fontSize: 14, color: _theme.disabledColor)),
                                    ],
                                  ),
                                ),
                              ) : Text(''),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text('$nbImages ${nbImages == 1 ? 'photo' : 'photos'}', style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color, fontWeight: FontWeight.w300)),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        ),
      ),
      floatingActionButton: _isEditMode ?
        Text("") :
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: <Widget>[
              widget.isAdmin? Align(
                alignment: Alignment.bottomRight,
                child: createUploadActionButton(),
              ) : Container(),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(bottom: 0, right: widget.isAdmin? 70 : 0),
                  child: FloatingActionButton(
                    backgroundColor: Color(0xaa868686),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Icon(Icons.home, color: Colors.grey.shade200, size: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      bottomNavigationBar: _isEditMode ? bottomBar() : Container(height: 0),
    );
  }

  Widget createUploadActionButton() {
    ThemeData _theme = Theme.of(context);
    return SpeedDial(
      marginEnd: 10,
      marginBottom: 17,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      closeManually: false,
      curve: Curves.bounceIn,
      backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
      foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
      elevation: 8.0,
      overlayOpacity: 0.1,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(Icons.create_new_folder),
          backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
          foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
          onTap: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return createCategoryAlert(context, widget.category);
              }
            ).whenComplete(() {
              setState(() {
                print('refresh');
              });
            });
          },
        ),
        SpeedDialChild(
            child: Icon(Icons.image),
            backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
            foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
            onTap: () async {
              try {
                var imageList = await MultiImagePicker.pickImages(
                  maxImages: 100,
                  enableCamera: true,
                  cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
                  materialOptions: MaterialOptions(
                    actionBarTitle: "Piwigo",
                    allViewTitle: "All Photos",
                    actionBarColor: "#ffff7700",
                    actionBarTitleColor: "#ffeeeeee",
                    lightStatusBar: false,
                    statusBarColor: '#ffab40',
                    startInAllView: false,
                    selectCircleStrokeColor: "#ffffff",
                    selectionLimitReachedText: "You can't select any more.",
                  ),
                );
                if(imageList.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UploadGalleryViewPage(imageData: imageList, category: widget.category)
                  ));
                }
              } catch (e) {
                print('Dio error ${e.toString()}');
              }
            }
        )
      ],
    );
  }

  Widget bottomBar() {
    ThemeData _theme = Theme.of(context);
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.file_upload, color: _theme.iconTheme.color),
          label: "upload",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.reply_outlined, color: _theme.iconTheme.color),
          label: "share",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.delete_outline, color: _theme.errorColor),
          label: "delete",
        ),
      ],
      backgroundColor: _theme.scaffoldBackgroundColor,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 16,
      unselectedFontSize: 16,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: 0,
    );
  }
}