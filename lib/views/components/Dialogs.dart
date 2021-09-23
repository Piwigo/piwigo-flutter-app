import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/api/TagAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/model/CategoryModel.dart';
import 'package:piwigo_ng/services/MoveAlbumService.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/components/Buttons.dart';
import 'package:piwigo_ng/views/components/TextFields.dart';

import 'CustomShapes.dart';
import 'SnackBars.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({Key key, this.content, this.yes, this.no, this.yesColor}) : super(key: key);
  final String content;
  final Text yes;
  final Text no;
  final Color yesColor;

  double _getWidth(context) {
    if(isPortrait(context)) {
      return MediaQuery.of(context).size.width/2;
    }
    return MediaQuery.of(context).size.height/2;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: AlertDialog(
        contentPadding: EdgeInsets.all(10.0),
        backgroundColor: Colors.transparent,
        content: Container(
          width: _getWidth(context),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  alignment: Alignment.center,
                  child: Text(
                    (content != null) ? '$content' : appStrings(context).deleteCategoryConfirm_title,
                    softWrap: true,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).disabledColor,
                        ),
                        child: TextButton(
                          child: no,
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: yesColor,
                        ),
                        child: TextButton(
                          child: yes,
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ),
                    ),
                  ]
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, false);
        return true;
      },
    );
  }
}

class MultiConfirmDialog extends StatelessWidget {
  const MultiConfirmDialog({Key key, this.content, this.actions, this.no}) : super(key: key);
  final String content;
  final List<Widget> actions;
  final Text no;

  @override
  Widget build(BuildContext context) {
    List<Widget> actionsRow = [];
    actions.forEach((action) {
      actionsRow.add(Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: TextButton(
          child: action,
          onPressed: () => Navigator.pop(context, actions.indexOf(action)),
        ),
      ));
      if(actions.last != action) actionsRow.add(SizedBox(height: 5.0));
    });

    return WillPopScope(
      child: AlertDialog(
        contentPadding: EdgeInsets.all(10.0),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  alignment: Alignment.center,
                  child: Text(
                    (content != null) ? '$content' : appStrings(context).deleteCategoryConfirm_title,
                    softWrap: true,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Column(children: actionsRow),
                Divider(thickness: 1.0, height: 5.0, endIndent: 5.0, indent: 5.0),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).disabledColor,
                  ),
                  child: TextButton(
                    child: no,
                    onPressed: () => Navigator.pop(context, -1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, -1);
        return true;
      },
    );
  }
}


Future<bool> confirmDeleteDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Colors.red,
      yes: Text(appStrings(context).deleteCategoryConfirm_deleteButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmRemoveSelectionDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Colors.red,
      yes: Text(appStrings(context).alertRemoveButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmMoveDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Colors.green,
      yes: Text(appStrings(context).moveImage_title,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmAssignDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Colors.green,
      yes: Text(appStrings(context).copyImage_title,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmDownloadDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Colors.blue,
      yes: Text(appStrings(context).imageOptions_download,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmMoveImage(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Theme.of(context).colorScheme.primary,
      yes: Text(appStrings(context).alertMoveButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmAssignImage(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Theme.of(context).colorScheme.primary,
      yes: Text(appStrings(context).alertCopyButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<int> chooseMoveCopyImage(context, {content = ''}) async {
  final int confirm = await showDialog<int>(
    context: context,
    builder: (_) => MultiConfirmDialog(
      content: content,
      no: Text(appStrings(context).alertCancelButton, style: TextStyle(fontSize: 16, color: Colors.white)),
      actions: <Widget>[
        Text(appStrings(context).moveImage_title, style: TextStyle(fontSize: 16, color: Colors.white)),
        Text(appStrings(context).copyImage_title, style: TextStyle(fontSize: 16, color: Colors.white)),
      ],
    ),
  );

  return (confirm != null) ? confirm : -1;
}





class PiwigoDialog extends StatelessWidget {
  const PiwigoDialog({Key key,this.title = "", this.content, this.width, this.height}) : super(key: key);

  final String title;
  final Widget content;
  final double width;
  final double height;

  double _getWidth(context) {
    if(isPortrait(context)) {
      return MediaQuery.of(context).size.width*3/4;
    }
    return MediaQuery.of(context).size.height*3/4;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(10),
      child: Container(
        child: Stack(
          children: [
            height != null ?
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: ShapeDecoration(
                shape: DialogBackgroundShape(radius: 25),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              width: width ?? _getWidth(context),
              height: height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DialogHeader(title: title),
                    content,
                  ],
                ),
              ),
            ) : Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: ShapeDecoration(
                shape: DialogBackgroundShape(radius: 25),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              width: width ?? _getWidth(context),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DialogHeader(title: title),
                    content,
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0.0,
              top: 0.0,
              child: GestureDetector(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogHeader extends StatelessWidget {
  const DialogHeader({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /*
        Align(
          alignment: Alignment.topLeft,
          child: InkResponse(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: CircleAvatar(
              child: Icon(Icons.cancel, color: Theme.of(context.errorColor),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
         */
        Container(
          padding: EdgeInsets.all(5.0),
          alignment: Alignment.center,
          child: Text(title, style: Theme.of(context).textTheme.headline4),
        ),
      ],
    );
  }
}


class CreateCategoryDialog extends StatefulWidget {
  const CreateCategoryDialog({Key key, this.catId = "0"}) : super(key: key);

  final String catId;

  @override
  _CreateCategoryDialogState createState() => _CreateCategoryDialogState();
}
class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;
  TextEditingController _descController;
  bool _isLoading = false;

  @override
  void initState() {
    _nameController = TextEditingController();
    _descController = TextEditingController();

    _nameController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  bool _isNameEmpty() {
    return _nameController.text.toString() == ''
        || _nameController.text == null;
  }

  void onCreateAlbum() async {
    if (_isNameEmpty()) return null;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        var result = await addCategory(
            _nameController.text,
            _descController.text, widget.catId);

        if(result['stat'] == 'fail') {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              errorSnackBar(context, result['result'])
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              albumAddedSnackBar(context)
          );
          _nameController.text = "";
          _descController.text = "";
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoDialog(
      title: appStrings(context).createNewAlbum_title,
      content: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Center(
              child: Text(appStrings(context).createNewAlbum_message,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            isPortrait(context) ?
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextFieldRequired(
                    controller: _nameController,
                    hint: appStrings(context).createNewAlbum_placeholder,
                  ),
                ), // Title field
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextFieldDescription(
                    controller: _descController,
                    hint: appStrings(context).createNewAlbumDescription_placeholder,
                  ),
                ), // Description field
              ],
            ) : Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextFieldRequired(
                      controller: _nameController,
                      hint: appStrings(context).createNewAlbum_placeholder,
                    ),
                  ), // Title field
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextFieldDescription(
                      controller: _descController,
                      hint: appStrings(context).createNewAlbumDescription_placeholder,
                    ),
                  ), // Description field
                ),
              ],
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
                onPressed: onCreateAlbum,
              ),
            ), // Save Button
          ],
        ),
      ),
    );
  }
}

class EditCategoryDialog extends StatefulWidget {
  final int catId;
  final String catName;
  final String catDesc;
  final bool privacy;

  const EditCategoryDialog({Key key, this.catId, this.catName, this.catDesc, this.privacy}) : super(key: key);

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}
class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _editAlbumNameController;
  TextEditingController _editAlbumDescController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _editAlbumNameController = TextEditingController(text: widget.catName);
    _editAlbumDescController = TextEditingController(text: widget.catDesc);

    _editAlbumNameController.addListener(() {
      setState(() {});
    });
  }

  bool _isNameEmpty() {
    return _editAlbumNameController.text.toString() == ''
        || _editAlbumNameController.text == null;
  }

  void onEditAlbum() async {
    if (_isNameEmpty()) return null;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        var result = await editCategory(
            widget.catId,
            _editAlbumNameController.text,
            _editAlbumDescController.text
        );

        if(result['stat'] == 'fail') {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              errorSnackBar(context, result['result'])
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              albumEditedSnackBar(context)
          );
          _editAlbumNameController.text = "";
          _editAlbumDescController.text = "";
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoDialog(
      title: appStrings(context).renameCategory_title,
      content: Form(
        key: _formKey,
        child:  Column(
          children: <Widget>[
            Center(
              child: Text(appStrings(context).renameCategory_message,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            isPortrait(context) ?
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextFieldRequired(
                    controller: _editAlbumNameController,
                    hint: appStrings(context).createNewAlbum_placeholder,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: TextFieldDescription(
                    controller: _editAlbumDescController,
                    hint: appStrings(context).createNewAlbumDescription_placeholder,
                  ),
                ),
              ],
            ) : Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextFieldRequired(
                      controller: _editAlbumNameController,
                      hint: appStrings(context).createNewAlbum_placeholder,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextFieldDescription(
                      controller: _editAlbumDescController,
                      hint: appStrings(context).createNewAlbumDescription_placeholder,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: DialogButton(
                child: _isLoading?
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                  ) : Text(appStrings(context).categoryCellOption_rename,
                      style: TextStyle(fontSize: 16, color: Colors.white)
                  ),
                style: _isNameEmpty() ?
                  dialogButtonStyleDisabled(context) :
                  dialogButtonStyle(context),
                onPressed: onEditAlbum,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditImageSelectionDialog extends StatefulWidget {
  final int catId;
  final List<dynamic> images;

  const EditImageSelectionDialog({Key key, this.catId, this.images}) : super(key: key);

  @override
  _EditImageSelectionDialogState createState() => _EditImageSelectionDialogState();
}
class _EditImageSelectionDialogState extends State<EditImageSelectionDialog> {
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
              return int.parse(tag['id']);
            }).toList(),
            _privacyLevel
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
    Size _screenSize = MediaQuery.of(context).size;
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
                        ),
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

  Widget tagItem(dynamic tag, Animation<double> animation, {BorderRadius borderRadius, Border border}) {
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
              Text('${tag['name']}', style: Theme.of(context).textTheme.subtitle1),
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

class SelectTagDialog extends StatefulWidget {
  final Function(List<dynamic>) onConfirm;
  final List<dynamic> selectedTags;

  const SelectTagDialog(this.selectedTags, this.onConfirm, {Key key}) : super(key: key);

  @override
  _SelectTagDialogState createState() => _SelectTagDialogState();
}
class _SelectTagDialogState extends State<SelectTagDialog> {
  List<dynamic> _selectedTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTags.addAll(widget.selectedTags);
  }

  bool isSelected(dynamic tag) {
    for(var selectedTag in _selectedTags) {
      if(tag['id'] == selectedTag['id']) {
        return true;
      }
    }
    return false;
  }

  void onSelectTags() {
    setState(() {
      _isLoading = true;
    });
    widget.onConfirm(_selectedTags);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Size _screenSize = MediaQuery.of(context).size;
    return PiwigoDialog(
      title: appStrings(context).tags,
      content: FutureBuilder<Map<String,dynamic>>(
        future: getAdminTags(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            if(snapshot.data['stat'] == 'fail') {
              return Center(
                child: Text(appStrings(context).coreDataFetch_TagError),
              );
            }
            var tags = snapshot.data["result"]['tags'];
            tags.removeWhere((tag) {
              return isSelected(tag);
            });
            return Container(
              height: _screenSize.height*3/4,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(5),
                      child: Text(appStrings(context).tagsHeader_selected,
                        style: Theme.of(context).textTheme.headline5
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _selectedTags.length,
                        itemBuilder: (BuildContext context, int index) {
                          if(_selectedTags.length == 0) return Container();
                          Icon icon = Icon(Icons.remove_circle_outline, color: Colors.red);
                          Border border = Border(bottom: BorderSide(color: Theme.of(context).scaffoldBackgroundColor));
                          Function() onTap = () {
                            setState(() {
                              if(isSelected(_selectedTags[index])) _selectedTags.remove(_selectedTags[index]);
                            });
                          };
                          if(_selectedTags.length == 1) {
                            return tagItem(_selectedTags[index], icon,
                              borderRadius: BorderRadius.circular(10),
                              onTap: onTap,
                            );
                          }
                          if(index == 0) {
                            return tagItem(_selectedTags[index], icon,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                              border: border,
                              onTap: onTap,
                            );
                          }
                          if(index == _selectedTags.length-1) {
                            return tagItem(_selectedTags[index], icon,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                              onTap: onTap,
                            );
                          }
                          return tagItem(_selectedTags[index], icon,
                            border: border,
                            onTap: onTap,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appStrings(context).tagsHeader_notSelected,
                            style: Theme.of(context).textTheme.headline5
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CreateTagDialog();
                                  }
                              ).whenComplete(() {
                                setState(() {
                                  print('refresh');
                                });
                              });
                            },
                            child: Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tags.length,
                        itemBuilder: (BuildContext context, int index) {
                          if(tags.length == 0) return Container();
                          Icon icon = Icon(Icons.add_circle_outline, color: Colors.green);
                          Border border = Border(bottom: BorderSide(color: Theme.of(context).scaffoldBackgroundColor));
                          Function() onTap = () {
                            setState(() {
                              if(!isSelected(tags[index])) _selectedTags.add(tags[index]);
                            });
                          };
                          if(tags.length == 1) {
                            return tagItem(tags[index], icon,
                              borderRadius: BorderRadius.circular(10),
                              onTap: onTap,
                            );
                          }
                          if(index == 0) {
                            return tagItem(tags[index], icon,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                              border: border,
                              onTap: onTap,
                            );
                          }
                          if(index == tags.length-1) {
                            return tagItem(tags[index], icon,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                              onTap: onTap,
                            );
                          }
                          return tagItem(tags[index], icon,
                            border: border,
                            onTap: onTap,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: DialogButton(
                        child: _isLoading?
                          CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                          ) : Text(appStrings(context).alertConfirmButton,
                            style: TextStyle(fontSize: 16, color: Colors.white)
                          ),
                        onPressed: onSelectTags,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              constraints: BoxConstraints(
                maxWidth: _screenSize.width*3/4,
                maxHeight: _screenSize.width*3/4,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget tagItem(dynamic tag, Icon icon, {Function() onTap, BorderRadius borderRadius, Border border}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.zero,
        color: Theme.of(context).cardColor,
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            border: border ?? Border.fromBorderSide(BorderSide.none),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${tag['name']}', style: Theme.of(context).textTheme.subtitle1),
              icon,
            ],
          ),
        ),
      ),
    );
  }
}

class CreateTagDialog extends StatefulWidget {
  const CreateTagDialog({Key key}) : super(key: key);

  @override
  _CreateTagDialogState createState() => _CreateTagDialogState();
}
class _CreateTagDialogState extends State<CreateTagDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    _nameController = TextEditingController();

    _nameController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  bool _isNameEmpty() {
    return _nameController.text.toString() == ''
        || _nameController.text == null;
  }

  void onCreateTag() async {
    if (_isNameEmpty()) return null;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        var result = await createTag(
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
      title: appStrings(context).tagsAdd_title,
      content: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Center(
              child: Text(appStrings(context).tagsAdd_message,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: TextFieldRequired(
                controller: _nameController,
                hint: appStrings(context).tagsAdd_placeholder,
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
                onPressed: onCreateTag,
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

class MoveOrCopyDialog extends StatefulWidget {
  const MoveOrCopyDialog({
    Key key,
    this.isImage = false,
    this.catId = "0",
    this.onSelected,
    this.catName = "",
    this.title = "",
    this.subtitle = ""
  }) : super(key: key);

  final bool isImage;
  final String catId;
  final String catName;
  final String title;
  final String subtitle;
  final Function(CategoryModel) onSelected;

  @override
  _MoveOrCopyDialogState createState() => _MoveOrCopyDialogState();
}
class _MoveOrCopyDialogState extends State<MoveOrCopyDialog> {

  bool isActualCategory(dynamic root) {
    return root.children.map((e) => e.id).contains(widget.catId);
  }

  CategoryModel createAlbumTree(snapshot) {
    CategoryModel root = CategoryModel("0", "root", fullname: "root");
    snapshot.data['result']['categories'].forEach((cat) {
      List<int> rank = cat['global_rank'].split('.').map(int.parse).toList().cast<int>();
      CategoryModel newCat = CategoryModel(cat['id'], cat['name'], comment: cat['comment'], nbImages: cat['nb_images'].toString(), fullname: cat['fullname'], status: cat['status']);
      if(rank.length > 1) {
        CategoryModel nextInputCat = root.children.elementAt(rank.first-1);
        rank.removeAt(0);
        addCatRecursive(rank, newCat, nextInputCat);
      } else {
        root.children.add(newCat);
      }
    });
    return root;
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoDialog(
      height: MediaQuery.of(context).size.height*0.8,
      title: widget.title,
      content: FutureBuilder<Map<String,dynamic>>(
        future: getAlbumList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if(snapshot.data['stat'] == 'fail') {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text('Failed to load albums'),
                  ),
                  Text(snapshot.data['result']),
                ],
              );
            }
            CategoryModel root = createAlbumTree(snapshot);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(widget.subtitle, style: TextStyle(color: Theme.of(context).textTheme.subtitle1.color ,fontSize: 16)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListView.builder(
                        itemCount: 1,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return TreeViewNode(
                            node: root,
                            catId: widget.catId,
                            catName: widget.catName,
                            isImage: widget.isImage,
                            isRoot: true,
                            onSelected: widget.onSelected,
                          );
                        },
                      ),
                    ),
                  ]
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({Key key, this.errorMessage = "", this.errorTitle}) : super(key: key);

  final String errorTitle;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return PiwigoDialog(
      title: errorTitle ?? appStrings(context).errorHUD_label,
      content: Center(
        child: Text(errorMessage, style: Theme.of(context).textTheme.subtitle1),
      ),
    );
  }
}
