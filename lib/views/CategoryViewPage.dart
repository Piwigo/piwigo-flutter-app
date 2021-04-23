import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'dart:convert';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:poc_piwigo/api/API.dart';
import 'package:poc_piwigo/api/CategoryAPI.dart';
import 'package:poc_piwigo/services/MoveAlbumService.dart';
import 'package:poc_piwigo/ui/Dialogs.dart';
import 'package:poc_piwigo/ui/ListItems.dart';
import 'package:poc_piwigo/ui/SnackBars.dart';

import 'ImageViewPage.dart';
import 'UploadGalleryViewPage.dart';



class CategoryViewPage extends StatefulWidget {
  CategoryViewPage({Key key, this.title, this.category, this.isAdmin}) : super(key: key);
  final bool isAdmin;
  final String title;
  final String category;

  @override
  _CategoryViewPageState createState() => _CategoryViewPageState();
}

class _CategoryViewPageState extends State<CategoryViewPage> with SingleTickerProviderStateMixin {
  bool _isEditMode;
  Map<int, bool> _selectedItems = Map();
  Map<int, bool> _swipedItems = Map();


  @override
  void initState() {
    super.initState();
    _isEditMode = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> fetchImages(String albumID) async {

    Map<String, String> queries = {
      "format":"json",
      "method": "pwg.categories.getImages",
      "cat_id":albumID
    };

    Response response = await API.dio.get('ws.php', queryParameters: queries);

    if (response.statusCode == 200) {
      var data = json.decode(response.data)["result"]["images"];
      return data;
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            centerTitle: true,
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
              int nbPhotos = 0;
              if(albums.data.length > 0) nbPhotos = albums.data[0]["total_nb_images"];
              albums.data.removeWhere((category) =>
                (category["id"].toString() == widget.category)
              );
              return FutureBuilder<List<dynamic>>(
                  future: fetchImages(widget.category), // Images of the list
                  builder: (BuildContext context, AsyncSnapshot images) {
                    if (images.hasData) {
                      return RefreshIndicator(
                        displacement: 20,
                        onRefresh: () {
                          setState(() {
                            print("refresh");
                          });
                          return Future.delayed(Duration(milliseconds: 1000));
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                itemCount: albums.data.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => CategoryViewPage(
                                          title: albums.data[index]["name"],
                                          category: albums.data[index]["id"].toString(),
                                          isAdmin: widget.isAdmin,
                                        )),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 5, bottom: 5),
                                      decoration: BoxDecoration(
                                      ),
                                      child: Slidable(
                                        actionPane: SlidableDrawerActionPane(),
                                        actionExtentRatio: 0.15,
                                        child: categoryListCard(context, albums.data[index], widget.isAdmin),
                                        secondaryActions: <Widget>[
                                          /*
                                          IconSlideAction(
                                            color: _theme.iconTheme.color,
                                            iconWidget: Icon(Icons.edit, size: 38, color: _theme.accentIconTheme.color),
                                            onTap: () {
                                              // TODO: Add edit album view
                                              print('Edit');
                                            },
                                          ),
                                           */
                                          IconSlideAction(
                                            color: Color(0xFF4B4B4B),
                                            iconWidget: Icon(Icons.reply, size: 38, color: _theme.accentIconTheme.color),
                                            onTap: () async {
                                              var result = await moveCategoryModalBottomSheet(context,
                                                albums.data[index]['id'].toString(),
                                                albums.data[index]['name']
                                              );
                                              setState(() {
                                                print('Moved album $result');
                                              });
                                            },
                                          ),
                                          Container(
                                            height: 130,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                              color: _theme.errorColor,
                                            ),
                                            child: IconSlideAction(
                                              color: Colors.transparent,
                                              iconWidget: Icon(Icons.delete, size: 38, color: _theme.accentIconTheme.color),
                                              onTap: () async {
                                                if (await confirm(
                                                  context,
                                                  title: Text('Confirm'),
                                                  content: Text('Delete ${albums.data[index]["name"]} ?', softWrap: true, maxLines: 3),
                                                  textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                                                  textCancel: Text('No', style: TextStyle(color: _theme.errorColor)),
                                                )) {
                                                  print("delete ${albums.data[index]["name"]}");
                                                  var result = await deleteCategory(albums.data[index]['id'].toString());
                                                  ScaffoldMessenger.of(context).showSnackBar(albumDeletedSnackBar(albums.data[index]["name"]));
                                                  setState(() {
                                                    print('Delete album ${albums.data[index]["name"]} : $result');
                                                  });
                                                }
                                              },
                                              closeOnTap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 3.0,
                                  crossAxisSpacing: 3.0,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                itemCount: images.data.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  if(_selectedItems.isEmpty) {
                                    images.data.forEach((item) {
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
                                          images: images.data,
                                          index: index,
                                          isAdmin: widget.isAdmin,
                                        )),
                                      );
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        alignment: Alignment.center,
                                        child: Stack(
                                          children: [
                                            Image.network(images.data[index]["derivatives"]["square"]["url"]),
                                            _isEditMode ? Container(
                                              child: _isSelected(index) ?
                                              Icon(Icons.check_circle, color: Colors.orange) :
                                              Icon(Icons.check_circle_outline, color: Colors.grey),
                                            ) : Text(""),
                                          ],
                                        )
                                    ),
                                  );
                                },
                              ),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text("$nbPhotos photos", style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color, fontWeight: FontWeight.w300)),
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
                print(e.toString());
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