import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/model/TagModel.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/components/buttons.dart';
import 'package:piwigo_ng/views/components/textfields.dart';

import 'package:piwigo_ng/views/components/snackbars.dart';
import 'confirm_dialogs.dart';
import 'piwigo_dialog.dart';
import 'tags_dialogs.dart';



class EditImageSelectionDialog extends StatefulWidget {
  final int catId;
  final List<dynamic> images;

  const EditImageSelectionDialog({Key key, this.catId, this.images}) : super(key: key);

  @override
  _EditImageSelectionDialogState createState() => _EditImageSelectionDialogState();
}
class _EditImageSelectionDialogState extends State<EditImageSelectionDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  List<DropdownMenuItem<int>> _levelItems = [];
  List<TagModel> _tags = [];
  List<TagModel> _currentTags = [];
  int _page = 0;
  int _privacyLevel = -1;
  bool _isLoading = false;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

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

  bool isNameEmpty() {
    return _nameController.text == ""
        || _nameController.text == null;
  }

  void onEditSelection() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        int nbEdited = await editImages(context,
          widget.images.map<Map<String,dynamic>>((image) {
            return {
              'id': image['id'],
              'name': _nameController.text,
              'desc': _descController.text,
            };
          }).toList(),
          _tags.map<int>((tag) {
            return tag.id;
          }).toList(),
          _privacyLevel,
        );
        ScaffoldMessenger.of(context).showSnackBar(
            imagesEditedSnackBar(context, nbEdited)
        );
        Navigator.of(context).pop();
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  void onRemoveImage() async {
    if(await confirmRemoveSelectionDialog(context,
      content: appStrings(context).removeSelectedImage_message,
    )) {
      if(widget.images.length == 1) {
        Navigator.of(context).pop();
      } else {
        int page = _page;
        if(_page == widget.images.length-1) {
          _page--;
        }
        setState(() {
          widget.images.removeAt(page);
        });
      }
    }
  }

  double _getWidth() {
    if(isPortrait(context)) {
      return MediaQuery.of(context).size.width*7/8;
    }
    return MediaQuery.of(context).size.height*7/8;
  }

  @override
  Widget build(BuildContext context) {
    if(isPortrait(context)) {
      _pageController = PageController(viewportFraction: 7/8);
    } else {
      _pageController = PageController(viewportFraction: 2/4);
    }

    return PiwigoDialog(
      title: appStrings(context).imageOptions_edit,
      width: _getWidth(),
      content: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
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
                children: widget.images.map<Widget>((image) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Stack(
                      children: [
                        /*Positioned(
                          top: 0,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context.inputDecorationTheme.fillColor,
                            ),
                            child: FaIcon(FontAwesomeIcons.solidEdit, color: Theme.of(context.inputDecorationTheme.fillColor),
                          ),
                        ),*/
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
                                  child: Image.network(image['derivatives']['square']['url'], fit: BoxFit.cover),
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
                                      Text('${image['file']}', style: Theme.of(context).textTheme.bodyText2, overflow: TextOverflow.fade),
                                      // Text('${image['date_creation']}', style: Theme.of(context.textTheme.bodyText2, overflow: TextOverflow.fade),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        widget.images.length > 1 ?
                          Positioned(
                            bottom: 0,
                            right: 10,
                            child: InkWell(
                              onTap: onRemoveImage,
                              child: Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                ),
                                child: Icon(Icons.remove_circle_outline, color: Theme.of(context).errorColor),
                              ),
                            )
                          ) : SizedBox(),
                        /*
                        Positioned(
                          top: 0,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return RenameImageDialog(
                                    imageId: widget.images[_page]['id'],
                                    imageName: widget.images[_page]['file'],
                                  );
                                }
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(3),
                              child: FaIcon(FontAwesomeIcons.solidEdit, color: Theme.of(context.iconTheme.color, size: 20),
                            ),
                          ),
                        ),
                         */
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(
              thickness: 1,
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
              padding: EdgeInsets.only(top: 5, bottom: 15),
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
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SelectTagDialog(_currentTags, (tags) {
                          setState(() {
                            tags.forEach((tag) {
                              if(!_tags.contains(tag)) _tags.insert(tags.indexOf(tag), tag);
                            });
                            _currentTags.clear();
                            _currentTags.addAll(tags);
                          });
                        });
                      }
                    );
                  },
                  child: Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _currentTags.isEmpty ? TagItem(
                TagModel(0, appStrings(context).none),
                isEnd: true,
              ) : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _tags.length,
                itemBuilder: (context, index) {
                  TagModel tag = _tags[index];
                  return TagItem(tag,
                    isExpanded: _currentTags.contains(tag),
                    isEnd: _currentTags.contains(tag) && tag == _currentTags.last,
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                    onTap: () {
                      setState(() {
                        _currentTags.removeWhere((e) => e.id == tag.id);
                      });
                    },
                  );
                },
              ),
            ),
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
            ), // Privacy
            Padding(
              padding: EdgeInsets.all(5.0),
              child: DialogButton(
                child: _isLoading?
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                ) : Text(appStrings(context).alertConfirmButton,
                    style: TextStyle(fontSize: 16, color: Colors.white)
                ),
                onPressed: onEditSelection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RenameImageDialog extends StatefulWidget {
  const RenameImageDialog({Key key, this.imageId, this.imageName}) : super(key: key);

  final int imageId;
  final String imageName;

  @override
  _RenameImageDialogState createState() => _RenameImageDialogState();
}
class _RenameImageDialogState extends State<RenameImageDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.imageName);

    _nameController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  bool _isNameEmpty() {
    return _nameController.text.toString() == ''
        || _nameController.text == null;
  }

  void onRename() async {
    if (_isNameEmpty()) return null;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        var result = await renameImage(
          widget.imageId,
          _nameController.text,
        );

        if(result['stat'] == 'fail') {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              errorSnackBar(context, result['result'])
          );
        } else {
          _nameController.text = "";
          Navigator.of(context).pop();
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoDialog(
      title: appStrings(context).renameImage_title,
      content: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Center(
              child: Text(appStrings(context).renameImage_message(widget.imageName),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: TextFieldRequired(
                controller: _nameController,
                hint: appStrings(context).editImageDetails_titlePlaceholder,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: DialogButton(
                child: _isLoading?
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                ) : Text(appStrings(context).alertAddButton,
                    style: TextStyle(fontSize: 16, color: Colors.white)
                ),
                style: _isNameEmpty() ?
                dialogButtonStyleDisabled(context) :
                dialogButtonStyle(context),
                onPressed: onRename,
              ),
            ),
          ],
        ),
      ),
    );
  }
}