import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:mime_type/mime_type.dart';

import 'package:flutter/material.dart';

import 'package:piwigo_ng/views/components/buttons.dart';
import 'package:piwigo_ng/views/components/textfields.dart';
import 'package:piwigo_ng/views/components/dialogs/dialogs.dart';

import '../model/TagModel.dart';

class UploadGalleryViewPage extends StatefulWidget {
  final List<XFile> imageData;
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
  List<TagModel> _tags = [];
  int _page = 0;
  int _privacyLevel = -1;
  bool _isLoading = false;
  PageController _pageController;
  bool _displayGrid = false;

  bool _isFilesLoading = false;

  @override
  void initState() {
    super.initState();
    imageCache.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      privacyLevels(context).forEach((key, value) {
        _levelItems.add(DropdownMenuItem<int>(
          value: key,
          child: Tooltip(
            message: value,
            child: Text(value, overflow: TextOverflow.fade),
          ),
        ));
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  int getGridColumns(int nbElements) {
    return (MediaQuery.of(context).size.width/200).ceil();
  }

  Map<String, dynamic> getImagesInfo() {
    List<int> tagIds = _tags.map<int>((tag) {
      return tag.id;
    }).toList();
    return {
      'name': _nameController.text,
      'comment': _descController.text,
      'tag_ids': tagIds,
      'level': _privacyLevel
    };
  }

  addFiles() async {
    setState(() {
      _isFilesLoading = true;
    });
    try {
      List<XFile> mediaList = ((await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      )) ?.files ?? []).map<XFile>((e) => XFile(
        e.path,
        name: e.name,
        bytes: e.bytes,
      )).toList();
      if(mediaList.isNotEmpty) {
        setState(() {
          widget.imageData.addAll(mediaList);
        });
      }
    } catch (e) {
      print('${e.toString()}');
    }
    setState(() {
      _isFilesLoading = false;
    });
  }
  takePhoto() async {
    setState(() {
      _isFilesLoading = true;
    });
    try {
      final XFile image = await ImagePicker().pickImage(source: ImageSource.camera);
      if(image != null) {
        setState(() {
          widget.imageData.add(image);
        });
      }
    } catch (e) {
      print('Dio error ${e.toString()}');
    }
    setState(() {
      _isFilesLoading = false;
    });
  }

  onRemoveFile() async {
    if(await confirmRemoveSelectionDialog(context,
      content: appStrings(context).removeSelectedImage_message,
    )) {
      int page = _page;
      if(_page == widget.imageData.length-1) {
        _page--;
      }
      setState(() {
        widget.imageData.removeAt(page);
      });
    }
  }
  onUpload() async {
    setState(() {
      _isLoading = true;
    });
    await API.uploader.uploadPhotos(context, widget.imageData, widget.category, getImagesInfo());

    if(mounted) {
      setState(() {
        _isLoading = false;
        widget.imageData.clear();
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if(isPortrait(context)) {
      _pageController = PageController(viewportFraction: 7/8);
    } else {
      _pageController = PageController(viewportFraction: 2/4);
    }

    List<Widget> horizontalList = widget.imageData.map<Widget>(
      (image) => _buildHorizontalListItem(image),
    ).toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
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
            onPressed: onUpload,
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
                  child: Text(appStrings(context).imageCount(widget.imageData.length),
                      style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText2.color)
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconSwitch(
                      isOnLeft: _displayGrid,
                      onTap: () {
                        setState(() {
                          _displayGrid = !_displayGrid;
                        });
                      },
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: addFiles,
                          child: Icon(Icons.add_to_photos, color: Theme.of(context).iconTheme.color),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(10),
                            primary: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: takePhoto,
                          child: Icon(Icons.photo_camera_rounded, color: Theme.of(context).iconTheme.color),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(10),
                            primary: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _isFilesLoading ?
                LinearProgressIndicator():
                SizedBox(),
              _displayGrid ?
                Container(
                  padding: EdgeInsets.all(10),
                  child: GridView.builder(
                    cacheExtent: 999999,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: getGridColumns(widget.imageData.length),
                    ),
                    itemCount: widget.imageData.length + (_isFilesLoading ? 1 : 0),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      if(_isFilesLoading && index == widget.imageData.length)
                        return CircularProgressIndicator();
                      XFile image = widget.imageData[index];
                      return _buildGridItem(image);
                    },
                  ),
                ) :
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
                    children: horizontalList,
                  ),
                ),
              Divider(
                thickness: 1,
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(appStrings(context).imageUploadDetailsEdit_title,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(appStrings(context).editImageDetails_title,
                            style: Theme.of(context).textTheme.headline5
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
                            style: Theme.of(context).textTheme.headline5
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
                              style: Theme.of(context).textTheme.headline5
                          ),
                          IconButton(
                            tooltip: appStrings(context).tagsTitle_selectOne,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => SelectTagsPage(
                                  selectedTags: _tags,
                                  onConfirm: (tags) {
                                    setState(() {
                                      tags.forEach((tag) {
                                        if(!_tags.contains(tag)) {
                                          _tags.insert(tags.indexOf(tag), tag);
                                          _listKey.currentState.insertItem(tags.indexOf(tag));
                                        }
                                      });
                                    });
                                  }
                                ))
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
                                border: Border(bottom: BorderSide(color: Theme.of(context).scaffoldBackgroundColor)),
                              );
                            }
                            if(index == _tags.length-1) {
                              return tagItem(_tags[index], animation,
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                              );
                            }
                            return tagItem(_tags[index], animation,
                              border: Border(bottom: BorderSide(color: Theme.of(context).scaffoldBackgroundColor)),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(appStrings(context).editImageDetails_privacyLevel,
                            style: Theme.of(context).textTheme.headline5
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).inputDecorationTheme.fillColor
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
              ),
              Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                child: DialogButton(
                  style: dialogButtonStyle(context),
                  onPressed: onUpload,
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

  Widget _buildHorizontalListItem(XFile image) {
    String mimeType = mime(image.path);
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
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: mimeType.startsWith('video')
                        ? VideoItem(path: image.path)
                        : Image.file(File(image.path),
                      fit: BoxFit.cover,
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
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${image.path.split('/').last}', style: Theme.of(context).textTheme.bodyText2, overflow: TextOverflow.fade),
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
                onTap: onRemoveFile,
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Icon(Icons.remove_circle_outline, color: Theme.of(context).errorColor),
                ),
              )
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(XFile image) {
    String mimeType = mime(image.path);
    return Container(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Card(
              elevation: 0,
              semanticContainer: true,
              child: GridTile(
                child: Container(
                  child: mimeType.startsWith('video')
                      ? VideoItem(path: image.path)
                      : Image.file(File(image.path),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: -5,
              right: -5,
              child: InkWell(
                onTap: onRemoveFile,
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15)),
                    // shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Icon(Icons.remove_circle_outline, color: Theme.of(context).errorColor),
                ),
              )
          ),
        ],
      ),
    );
  }

  Widget tagItem(TagModel tag, Animation<double> animation, {BorderRadius borderRadius, Border border}) {
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
              Text('${tag.name}', style: Theme.of(context).textTheme.subtitle1),
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
}

class VideoItem extends StatefulWidget {
  const VideoItem({Key key, this.path}) : super(key: key);

  final String path;

  @override
  _VideoItemState createState() => _VideoItemState();
}
class _VideoItemState extends State<VideoItem> {
  BetterPlayerController _controller;

  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource.file(widget.path);
    _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          aspectRatio: 1,
          autoPlay: true,
          looping: true,
          fit: BoxFit.cover,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControls: false
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _controller.isPlaying()
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: AspectRatio(
          aspectRatio: 1,
          child: BetterPlayer(controller: _controller),
        )
      );
  }
}
