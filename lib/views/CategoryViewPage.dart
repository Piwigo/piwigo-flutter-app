import 'package:auto_size_text/auto_size_text.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';

import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/services/MoveAlbumService.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/components/Dialogs.dart';
import 'package:piwigo_ng/views/components/ListItems.dart';
import 'package:piwigo_ng/views/components/SnackBars.dart';

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
  Map<int, dynamic> _selectedItems = Map();
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
    var response = await fetchImages(widget.category, _page);
    if(response['stat'] == 'fail') {
      ScaffoldMessenger.of(context).showSnackBar(
          errorSnackBar(context, response['result'])
      );
    } else {
      var newListPage = response['result']['images'];
      imageList.addAll(newListPage);
    }
    setState(() {
      print('Fetch images of page $_page');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isSelected(int id) {
    return _selectedItems.keys.contains(id);
  }

  int _selectedPhotos() {
    return _selectedItems.length;
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
            iconTheme: IconThemeData(
              color: _theme.iconTheme.color,//change your color here
            ),
            leading: _isEditMode ? IconButton(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                });
                _selectedItems.clear();
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
                  if(_selectedItems.length > 0) {
                    print('Edit: ${_selectedItems.keys}');
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return EditImageSelectionDialog(
                            catId: int.parse(widget.category),
                            images: _selectedItems.values.toList(),
                          );
                        }
                    ).whenComplete(() {
                      print('Edited ${_selectedItems.length} images');
                      setState(() {
                        _selectedItems.clear();
                        _isEditMode = false;
                      });
                    });
                  }
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
        body: FutureBuilder<Map<String,dynamic>>(
          future: fetchAlbums(widget.category), // Albums of the list
          builder: (BuildContext context, AsyncSnapshot albumSnapshot) {
            if (albumSnapshot.hasData) {
              if(albumSnapshot.data['stat'] == 'fail') {
                return Center(child: Text('Failed to load albums'));
              }
              var albums = albumSnapshot.data['result']['categories'];
              int nbImages = _nbImages;
              if(albums.length > 0 && albums[0]["id"].toString() == widget.category) {
                nbImages = albums[0]["total_nb_images"];
                _nbImages = nbImages;
              }
              albums.removeWhere((category) =>
                (category["id"].toString() == widget.category)
              );
              return FutureBuilder<Map<String,dynamic>>(
                future: fetchImages(widget.category, 0), // Images of the list
                builder: (BuildContext context, AsyncSnapshot imagesSnapshot) {
                  if (imagesSnapshot.hasData) {
                    if (imageList.isEmpty || _page == 0) {
                      if(imagesSnapshot.data['stat'] == 'fail') {
                        return Center(child: Text('Failed to load images'));
                      }
                      imageList.clear();
                      imageList.addAll(imagesSnapshot.data['result']['images']);
                    }
                    return RefreshIndicator(
                      displacement: 20,
                      notificationPredicate: (notification) {
                        return notification.metrics.atEdge;
                      },
                      onRefresh: () {
                        setState(() {
                          _page = 0;
                        });
                        return Future.delayed(Duration(milliseconds: 500));
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            /*
                            ListView.builder(
                              itemCount: albums.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return albumListItem(context, albums[index], widget.isAdmin, (message) {
                                  setState(() {
                                    print('$message');
                                  });
                                });
                              },
                            ),
                             */
                            albums.length > 0 ?
                            GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isPortrait(context)? 1 : 2,
                                mainAxisSpacing: 3,
                                crossAxisSpacing: 5,
                                childAspectRatio: albumGridAspectRatio(context),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              itemCount: albums.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                var album = albums[index];
                                if (isPortrait(context) || index%2 == 0) {
                                  return albumListItem(context, album, widget.isAdmin, (message) {
                                    setState(() {
                                      print('$message');
                                    });
                                  });
                                }
                                return albumListItemRight(context, album, widget.isAdmin, (message) {
                                  setState(() {
                                    print('$message');
                                  });
                                });
                              },
                            ) : Text(''),
                            imageList.length > 0 ?
                            GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: imageCrossAxisCount(context),
                                mainAxisSpacing: 3.0,
                                crossAxisSpacing: 3.0,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              itemCount: imageList.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                var image = imageList[index];
                                return InkWell(
                                  onLongPress: _isEditMode ? () {
                                    setState(() {
                                      _isSelected(image['id']) ?
                                      _selectedItems.remove(image['id']) :
                                      _selectedItems.putIfAbsent(image['id'], () => image);
                                    });
                                  } : widget.isAdmin ? () {
                                    setState(() {
                                      _isEditMode = true;
                                      _selectedItems.putIfAbsent(image['id'], () => image);
                                    });
                                  } : () {},
                                  onTap: () {
                                    _isEditMode ?
                                    setState(() {
                                      _isSelected(image['id']) ?
                                      _selectedItems.remove(image['id']) :
                                      _selectedItems.putIfAbsent(image['id'], () => image);
                                    }) :
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => ImageViewPage(
                                        images: imageList,
                                        index: index,
                                        isAdmin: widget.isAdmin,
                                        category: widget.category,
                                      )),
                                    ).whenComplete(() {
                                      setState(() {});
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: _isSelected(image['id']) ?
                                        Border.all(width: 5, color: _theme.accentColor) :
                                        Border.all(width: 0, color: Colors.white),
                                      /*
                                      image: DecorationImage(
                                        image: Image.network(imageList[index]["derivatives"][API.prefs.getString('miniature_size')]["url"]).image,
                                        fit: BoxFit.cover,
                                      ),
                                       */
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: Image.network(imageList[index]["derivatives"][API.prefs.getString('miniature_size')]["url"],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        _isSelected(image['id']) ? Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: Color(0x80000000),
                                        ) : Text(""),
                                        /*
                                        _isEditMode? Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: _isSelected(image['id']) ?
                                              Icon(Icons.check_circle, color: _theme.floatingActionButtonTheme.backgroundColor) :
                                              Icon(Icons.check_circle_outline, color: _theme.disabledColor),
                                          ),
                                        ) : Text(""),

                                         */
                                        API.prefs.getBool('show_miniature_title')? Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: double.infinity,
                                            color: Color(0x80ffffff),
                                            child: AutoSizeText('${image['name']}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(fontSize: 12),
                                              maxFontSize: 14, minFontSize: 7,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ) : Text(""),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ) : Text(''),
                            nbImages > (_page+1)*100 ? GestureDetector(
                              onTap: () {
                                showMore();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Show ${nbImages-((_page+1)*100)} more ...', style: TextStyle(fontSize: 14, color: _theme.disabledColor)),
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
          labelWidget: Text('New Album', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _theme.buttonColor)),
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
          labelWidget: Text('Upload File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _theme.buttonColor)),
          child: Icon(Icons.add_a_photo),
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
      onTap: (index) async {
        switch (index) {
          case 0:
            if(_selectedItems.length > 0) {
              if(await confirm(context,
                title: Text('Confirm'),
                content: Text('Download ${_selectedItems.keys.length} images ?', softWrap: true, maxLines: 3),
                textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
              )) {
                print('Download ${_selectedItems.keys.toList()}');

                List<dynamic> selection = [];
                selection.addAll(_selectedItems.values.toList());

                setState(() {
                  _isEditMode = false;
                  _selectedItems.clear();
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Downloading selection'),
                      CircularProgressIndicator(),
                    ],
                  ),
                ));

                await downloadImages(selection);
              }
            }
            break;
          case 1:
            if(_selectedItems.length > 0) {
              print('Move ${_selectedItems.keys}');
              await moveCategoryModalBottomSheet(context,
                widget.category,
                widget.title,
                true,
                (item) async {
                  String result = await confirmMoveAssignImage(
                    context,
                    title: Text('Confirm'),
                    content: Text('Move selection to ${item.name} ?',
                      softWrap: true,
                      maxLines: 3
                    ),
                  );
                  print(result);
                  if (result == 'move') {
                    print('Move selection to ${item.id}');
                    int nbMoved = await moveImages(context,
                      _selectedItems.values.toList(),
                      int.parse(item.id)
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      imagesMovedSnackBar(nbMoved, item.name)
                    );
                    Navigator.of(context).pop();
                  } else if (result == 'assign') {
                    print('Assign selection to ${item.id}');
                    int nbAssigned = await assignImages(context,
                      _selectedItems.values.toList(),
                      int.parse(item.id)
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      imagesAssignedSnackBar(nbAssigned, item.name)
                    );
                    Navigator.of(context).pop();
                  }
                },
              );
              setState(() {
                _isEditMode = false;
                _selectedItems.clear();
              });
            }
            break;
          case 2:
            if(_selectedItems.length > 0) {
              if(await confirm(context,
                title: Text('Confirm'),
                content: Text('Delete ${_selectedItems.keys.length} images ?', softWrap: true, maxLines: 3),
                textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
              )) {
                print('Delete ${_selectedItems.keys}');

                List<int> selection = [];
                selection.addAll(_selectedItems.keys.toList());

                setState(() {
                  _isEditMode = false;
                  _selectedItems.clear();
                });

                int nbSuccess = await deleteImages(context, selection);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Deleted ${selection.length} images'),
                ));
                setState(() {});
              }
            }
            break;
          default:
            break;
        }
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.download_rounded, color: _theme.iconTheme.color),
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