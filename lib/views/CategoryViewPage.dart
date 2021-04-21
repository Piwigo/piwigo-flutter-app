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
  CategoryViewPage({Key key, this.title, this.category}) : super(key: key);

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

  TextEditingController _searchTextController = new TextEditingController();
  String _filter;

  @override
  void initState() {
    super.initState();

    _filter = "";
    _isEditMode = false;
  }
  @override
  void dispose() {
    super.dispose();
  }

  bool _filterSearch(String name) {
    if(_filter != null) {
      if(!name.toLowerCase().contains(_filter.toLowerCase())) {
        return true;
      }
    }
    return false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: FutureBuilder<List<dynamic>>(
          future: fetchAlbums(widget.category), // Albums of the list
          builder: (BuildContext context, AsyncSnapshot albums) {
            if(albums.hasData){
              albums.data.removeWhere((category) => (
                  category["id"].toString() == widget.category || _filterSearch(category["name"].toString()))
              );
              return FutureBuilder<List<dynamic>>(
                  future: fetchImages(widget.category), // Images of the list
                  builder: (BuildContext context, AsyncSnapshot images) {
                    if(images.hasData) {
                      return CustomScrollView(
                        slivers: <Widget>[
                          SliverAppBar(
                            backgroundColor: Colors.grey.shade200,
                            pinned: true,
                            snap: false,
                            floating: false,
                            expandedHeight: 180.0,
                            iconTheme: IconThemeData(
                              color: Colors.orange, //change your color here
                            ),
                            title: _isEditMode ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
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
                                ),
                                Text("${_selectedPhotos()}", overflow: TextOverflow.fade, softWrap: true,),
                                IconButton(
                                  onPressed: () {
                                    List<int> selection = [];
                                    _selectedItems.forEach((key, value) {
                                      if(value) selection.add(key);
                                    });
                                    print('Selected: $selection');
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                              ],
                            ) : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(),
                                Text(widget.title),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditMode = true;
                                    });
                                  },
                                  icon: Icon(Icons.touch_app),
                                ),
                              ],
                            ),
                            flexibleSpace: FlexibleSpaceBar(
                              background: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Text("Albums", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextField(
                                      controller: _searchTextController,
                                      onChanged: (str) {
                                        setState(() {
                                          _filter = str;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        prefixIcon: new Icon(Icons.search, color: Colors.grey),
                                        hintText: "Search",
                                        hintStyle: new TextStyle(color: Colors.grey)
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.all(5),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
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
                                          )),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 5, bottom: 5),
                                        decoration: BoxDecoration(
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Colors.grey.withOpacity(0.5),
                                          //     spreadRadius: 2,
                                          //     blurRadius: 4,
                                          //     offset: Offset(0, 3), // changes position of shadow
                                          //   ),
                                          // ],
                                        ),
                                        child: Slidable(
                                          actionPane: SlidableDrawerActionPane(),
                                          actionExtentRatio: 0.15,
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(width: 0, color: Colors.white),
                                                  color: Colors.white,
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
                                                  color: Colors.white,
                                                ),
                                                width: 14,
                                                height: 130.0,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(width: 0, color: Colors.white),
                                                    color: Colors.white,
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  height: 130.0,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('${albums.data[index]["name"]}', style: TextStyle(color: Colors.orange, fontSize: 20)),
                                                      Column(
                                                        children: [
                                                          Text('${albums.data[index]["description"] == null ? "no description" : albums.data[index]["description"]}', style: TextStyle(color: Colors.grey)),
                                                          Container(
                                                            padding: EdgeInsets.all(5),
                                                            child: Text('${albums.data[index]["total_nb_images"]} photos', style: TextStyle(color: Colors.black)),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 130.0,
                                                decoration: BoxDecoration(
                                                  border: Border.all(width: 0, color: Colors.white),
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(10),
                                                    bottomRight: Radius.circular(10),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    width: 8,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(10),
                                                          bottomLeft: Radius.circular(10),
                                                        ),
                                                        color: Colors.orange
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          secondaryActions: <Widget>[
                                            IconSlideAction(
                                              color: Colors.orange,
                                              iconWidget: Icon(Icons.edit, size: 38, color: Colors.white),
                                              onTap: () {
                                                print('Edit');
                                              },
                                            ),
                                            IconSlideAction(
                                              color: Colors.black45,
                                              iconWidget: Icon(Icons.reply, size: 38, color: Colors.white),
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
                                                color: Colors.red,
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  print("delete");
                                                },
                                                icon: Icon(Icons.delete, size: 38, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  );
                                },
                                childCount: albums.data.length,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.all(5),
                            sliver: SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 3.0,
                                crossAxisSpacing: 3.0,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
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
                                childCount: images.data.length,
                              ),
                            ),
                          ),
                        ],
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
      floatingActionButton: _isEditMode ?
        Text("") :
        Stack(
        children: [
          createUploadActionButton(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(bottom: 0, right: 70),
                child: FloatingActionButton(
                  backgroundColor: Color(0xaa868686),
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  child: Icon(Icons.home, color: Colors.grey.shade200, size: 30),
                ),
              ),
            ),
          ],
        ),
      bottomNavigationBar: _isEditMode ? bottomBar() : Container(height: 0),
    );
  }


  Widget createUploadActionButton() {
    final _formKey = GlobalKey<FormState>();
    return SpeedDial(
      marginEnd: 10,
      marginBottom: 17,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      closeManually: true,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.1,
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(Icons.create_new_folder),
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
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
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
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
                    builder: (context) => UploadGalleryViewPage(imageData: imageList, category: widget.category,)
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
    return BottomNavigationBar(
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
      currentIndex: 0,
    );
  }
}