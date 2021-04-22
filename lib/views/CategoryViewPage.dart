import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'dart:convert';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:poc_piwigo/api/API.dart';

import '../ui/WeirdBorder.dart';
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
  final _addAlbumController = TextEditingController();
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

  Future<List<dynamic>> fetchAlbums(String albumID) async {

    Map<String, String> queries = {
      "format": "json",
      "method": "pwg.categories.getList",
      "cat_id": albumID
    };

    Response response = await API.dio.get('ws.php', queryParameters: queries);

    if (response.statusCode == 200) {
      return json.decode(response.data)["result"]["categories"];
    } else {
      throw Exception("bad request: "+response.statusCode.toString());
    }
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

  void addCategory(String catName) async {
    Map<String, String> queries = {
      "format": "json",
      "method": "pwg.categories.add",
      "name": catName,
      "parent": widget.category
    };

    Response response = await API.dio.post('ws.php', queryParameters: queries);

    if(response.statusCode == 200) {
      print(response.data);
      setState(() {
        print("refresh");
      });
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
          ),
        ],
        body: FutureBuilder<List<dynamic>>(
          future: fetchAlbums(widget.category), // Albums of the list
          builder: (BuildContext context, AsyncSnapshot albums) {
            if (albums.hasData) {
              int nbPhotos = albums.data[0]["total_nb_images"];
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
                                  if(_swipedItems.isEmpty) {
                                    albums.data.forEach((item) {
                                      _swipedItems[index] = false;
                                    });
                                  }
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
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(width: 0, color: _theme.backgroundColor),
                                                color: _theme.backgroundColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10),
                                                ),
                                              ),
                                              padding: EdgeInsets.all(5),
                                              height: 130.0,
                                              width: 130.0,
                                              child: albums.data[index]["tn_url"] == null ?
                                              Icon(Icons.image_not_supported_outlined, size: 50)
                                                  :
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(7.0),
                                                child: Image.network(
                                                  albums.data[index]["tn_url"],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: ShapeDecoration(
                                                shape: WeirdBorder(radius: 7),
                                                color: _theme.backgroundColor,
                                              ),
                                              width: 14,
                                              height: 130.0,
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(width: 0, color: _theme.backgroundColor),
                                                  color: _theme.backgroundColor,
                                                ),
                                                padding: EdgeInsets.all(5),
                                                height: 130.0,
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('${albums.data[index]["name"]}', style: _theme.textTheme.headline6),
                                                      Column(
                                                        children: [
                                                          Text('${albums.data[index]["description"] == null ?
                                                          "(no description)" :
                                                          albums.data[index]["description"]
                                                          }',
                                                              style: _theme.textTheme.subtitle1),
                                                          Container(
                                                            padding: EdgeInsets.all(5),
                                                            child: Text(albumSubCount(albums.data[index]),
                                                                style: Theme.of(context).textTheme.bodyText2
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 130.0,
                                              decoration: BoxDecoration(
                                                color: _theme.backgroundColor,
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight: Radius.circular(10),
                                                ),
                                              ),
                                              child: widget.isAdmin? Center(
                                                child: Container(
                                                  width: 8,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(width: 1, color: _theme.accentColor),
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(10),
                                                      bottomLeft: Radius.circular(10),
                                                    ),
                                                    color: _theme.accentColor,
                                                  ),
                                                ),
                                              ) : Container(width: 8),
                                            ),
                                          ],
                                        ),
                                        secondaryActions: <Widget>[
                                          IconSlideAction(
                                            color: _theme.iconTheme.color,
                                            iconWidget: Icon(Icons.edit, size: 38, color: _theme.accentIconTheme.color),
                                            onTap: () {
                                              print('Edit');
                                            },
                                          ),
                                          IconSlideAction(
                                            color: Color(0xFF4B4B4B),
                                            iconWidget: Icon(Icons.reply, size: 38, color: _theme.accentIconTheme.color),
                                            onTap: () {
                                              print('More');
                                            },
                                          ),
                                          Container(
                                            height: 130,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                              color: _theme.errorColor,
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                print("delete");
                                              },
                                              icon: Icon(Icons.delete, size: 38, color: _theme.accentIconTheme.color),
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
    final _formKey = GlobalKey<FormState>();
    return SpeedDial(
      marginEnd: 10,
      marginBottom: 17,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      closeManually: true,
      curve: Curves.bounceIn,
      // overlayColor: Colors.black,
      // overlayOpacity: 0.1,
      backgroundColor: _theme.floatingActionButtonTheme.backgroundColor,
      foregroundColor: _theme.floatingActionButtonTheme.foregroundColor,
      elevation: 8.0,
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
                return createCategoryAlert(_formKey);
              }
            );
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
                    allViewTitle: "Selecting photos",
                    actionBarColor: "#ff9800",
                    actionBarTitleColor: "#ffffff",
                    lightStatusBar: false,
                    statusBarColor: '#ffab40',
                    startInAllView: true,
                    selectCircleStrokeColor: "#ffffff",
                    selectionLimitReachedText: "You can't select any more.",
                  ),
                );

                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => UploadGalleryViewPage(imageData: imageList, category: widget.category)
                ));
              } catch (e){
                print(e.toString());
              }
            }
        )
      ],
    );
  }

  Widget createCategoryAlert(_formKey) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:[
              InkResponse(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  child: Icon(Icons.close),
                  backgroundColor: Colors.red,
                ),
              ),
            ]
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextFormField(
                    controller: _addAlbumController,
                    decoration: InputDecoration(
                        hintText: "Album name"
                    ),
                    validator: (value) {
                      if(value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ElevatedButton(
                    child: Text("Create album"),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        addCategory(_addAlbumController.text);
                        _addAlbumController.text = "";
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
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