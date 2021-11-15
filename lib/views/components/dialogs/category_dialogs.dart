import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/components/buttons.dart';

import 'piwigo_dialog.dart';
import 'package:piwigo_ng/views/components/snackbars.dart';


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
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      maxLines: 1,
                      controller: _nameController,
                      style: Theme.of(context).inputDecorationTheme.labelStyle,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: appStrings(context).createNewAlbum_placeholder,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                      ),
                    ),
                  ),
                  Divider(height: 5.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _descController,
                      minLines: 1,
                      maxLines: 5,
                      style: Theme.of(context).inputDecorationTheme.labelStyle,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: appStrings(context).createNewAlbumDescription_placeholder,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
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
        child: Column(
          children: <Widget>[
            Center(
              child: Text(appStrings(context).renameCategory_message,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      maxLines: 1,
                      controller: _editAlbumNameController,
                      style: Theme.of(context).inputDecorationTheme.labelStyle,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: appStrings(context).createNewAlbum_placeholder,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                      ),
                    ),
                  ),
                  Divider(height: 5.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _editAlbumDescController,
                      minLines: 1,
                      maxLines: 5,
                      style: Theme.of(context).inputDecorationTheme.labelStyle,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: appStrings(context).createNewAlbumDescription_placeholder,
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            DialogButton(
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
          ],
        ),
      ),
    );
  }
}