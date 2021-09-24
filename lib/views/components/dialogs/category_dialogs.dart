import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';
import 'package:piwigo_ng/views/components/buttons.dart';
import 'package:piwigo_ng/views/components/textfields.dart';

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