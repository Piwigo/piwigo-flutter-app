import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/api/API.dart';

import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'components/Dialogs.dart';
import 'components/TextFields.dart';

class UploadGalleryViewPage extends StatefulWidget {
  final List<Asset> imageData;
  final String category;

  UploadGalleryViewPage({Key key, this.imageData, this.category}) : super(key: key);

  @override
  _UploadGalleryViewPage createState() => _UploadGalleryViewPage();
}
class _UploadGalleryViewPage extends State<UploadGalleryViewPage> {
  final _formKey = GlobalKey<FormState>();
  final _listKey = GlobalKey<AnimatedListState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  List<DropdownMenuItem<int>> _levelItems = [];
  List<dynamic> _tags = [];
  int _page = 0;
  int _privacyLevel = -1;
  bool _isLoading = false;
  PageController _pageController;
  bool _showImages = false;
  bool _displayGrid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int getGridColumns(int nbElements) {
    if(nbElements < 4) return nbElements;
    if(nbElements < 10) return 3;
    return 4;
  }

  Map<String, dynamic> getImagesInfo() {
    return {
      'name': _nameController.text,
      'comment': _descController.text,
      'tag_ids': _tags,
      'level': _privacyLevel
    };
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    if(isPortrait(context)) {
      _pageController = PageController(viewportFraction: 7/8);
    } else {
      _pageController = PageController(viewportFraction: 2/4);
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: _theme.iconTheme,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        centerTitle: true,
        title: Text(appStrings(context).categoryUpload_images),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await API.uploader.uploadPhotos(widget.imageData, widget.category, getImagesInfo());
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.upload_file),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(appStrings(context).imageCount(widget.imageData.length), style: TextStyle(fontSize: 20, color: _theme.textTheme.bodyText2.color)),
                ),
              ),
              Text(appStrings(context).showPhotos),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _displayGrid ?
                            Colors.orange :
                            Colors.transparent,
                        ),
                        child: Icon(Icons.apps,
                          color: _displayGrid ?
                            Colors.white :
                            Colors.orange
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _displayGrid ?
                            Colors.transparent :
                            Colors.orange,
                        ),
                        child: Icon(Icons.description,
                          color: _displayGrid ?
                            Colors.orange :
                            Colors.white
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    _displayGrid = !_displayGrid;
                  });
                },
              ),

              Container(
                height: 150,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int) {
                    setState(() {
                      _page = int;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                  physics: PageScrollPhysics(),
                  children: widget.imageData.map<Widget>((image) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 130,
                                  width: 130,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _theme.inputDecorationTheme.fillColor,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: AssetThumb(
                                      asset: image,
                                      width: 100,
                                      height: 100,
                                      spinner: Text(""),
                                      quality: 50,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 110,
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      color: _theme.inputDecorationTheme.fillColor,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${image.name}', style: _theme.textTheme.bodyText2, overflow: TextOverflow.fade),
                                        Text('${image.metadata}', style: _theme.textTheme.bodyText2, overflow: TextOverflow.fade),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 10,
                              child: InkWell(
                                onTap: () {
                                  int page = _page;
                                  if(_page == widget.imageData.length-1) {
                                    _page--;
                                  }
                                  setState(() {
                                    widget.imageData.removeAt(page);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _theme.scaffoldBackgroundColor,
                                  ),
                                  child: Icon(Icons.remove_circle_outline, color: _theme.errorColor),
                                ),
                              )
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              Divider(
                thickness: 1,
              ),

              Container(
                padding: EdgeInsets.all(10),
                child: _showImages ? GridView.builder( // Put images on a grid
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: getGridColumns(widget.imageData.length),
                  ),
                  itemCount: widget.imageData.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Card(
                        elevation: 5,
                        semanticContainer: true,
                        child: GridTile(
                          child: Container(
                            child: AssetThumb(
                              asset: widget.imageData[index],
                              width: 300,
                              height: 300,
                              spinner: Text(""),
                              quality: 50,
                            ),
                          ),
                        ),
                      ),
                    );
                    /*
                    return FutureBuilder(
                      future: FlutterAbsolutePath.getAbsolutePath(widget.imageData[index].identifier),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          return createCardImage(context, snapshot.data);
                        } else {
                          return CircularProgressIndicator();
                        }
                      }
                    ); // Custom grid cells
                    */
                  }
                ) : Text(""),
              ),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(appStrings(context).editImageDetails_title,
                          style: _theme.textTheme.headline5
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 15),
                      child: TextFieldRequired(
                        controller: _nameController,
                        hint: appStrings(context).editImageDetails_titlePlaceholder,
                      ),
                    ), // Name
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(appStrings(context).editImageDetails_description,
                          style: _theme.textTheme.headline5
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: TextFieldDescription(
                        controller: _descController,
                        hint: appStrings(context).editImageDetails_descriptionPlaceholder,
                        minLines: 5,
                        maxLines: 10,
                        padding: EdgeInsets.all(10),
                      ),
                    ), // Description
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(appStrings(context).tagsAdd_title,
                            style: _theme.textTheme.headline5
                        ),
                        IconButton(
                          tooltip: appStrings(context).tagsTitle_selectOne,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SelectTagDialog(
                                    _tags, (tags) {
                                  setState(() {
                                    tags.forEach((tag) {
                                      if(!_tags.contains(tag)) {
                                        _tags.insert(tags.indexOf(tag), tag);
                                        _listKey.currentState.insertItem(tags.indexOf(tag));
                                      }
                                    });
                                  });
                                }
                                );
                              }
                            );
                          },
                          icon: Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: AnimatedList(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        key: _listKey,
                        initialItemCount: _tags.length,
                        itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                          if(_tags.length == 0) return Container();
                          if(_tags.length == 1) {
                            return tagItem(_tags[index], animation,
                              borderRadius: BorderRadius.circular(10),
                            );
                          }
                          if(index == 0) {
                            return tagItem(_tags[index], animation,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                              border: Border(bottom: BorderSide(color: _theme.scaffoldBackgroundColor)),
                            );
                          }
                          if(index == _tags.length-1) {
                            return tagItem(_tags[index], animation,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                            );
                          }
                          return tagItem(_tags[index], animation,
                            border: Border(bottom: BorderSide(color: _theme.scaffoldBackgroundColor)),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(appStrings(context).editImageDetails_privacyLevel,
                          style: _theme.textTheme.headline5
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _theme.inputDecorationTheme.fillColor
                        ),
                        child: DropdownButton<int>(
                          onTap: () {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          isExpanded: true,
                          underline: Container(),
                          value: _privacyLevel,
                          onChanged: (level) {
                            setState(() {
                              _privacyLevel = level;
                            });
                          },
                          style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                          items: _levelItems,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await API.uploader.uploadPhotos(widget.imageData, widget.category, getImagesInfo());
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xffff7700)),
                  ),
                  child: _isLoading?
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                    ) : Text(appStrings(context).imageUploadDetailsButton_title,
                      style: TextStyle(fontSize: 16, color: Colors.white)
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tagItem(dynamic tag, Animation<double> animation, {BorderRadius borderRadius, Border border}) {
    var _theme = Theme.of(context);

    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.zero,
          color: Theme.of(context).cardColor,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            border: border ?? Border.fromBorderSide(BorderSide.none),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${tag['name']}', style: _theme.textTheme.subtitle1),
              InkWell(
                onTap: () async {
                  _listKey.currentState.removeItem(_tags.indexOf(tag), (context, animation) => tagItem(tag, animation));
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                child: Icon(Icons.remove_circle_outline, color: Theme.of(context).errorColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*
  Widget createCardImage(BuildContext context, String imagePath) {
    return Container(
      child: Card(
        elevation: 5,
        semanticContainer: true,
        child: GridTile(
          child: Container(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
  */
}