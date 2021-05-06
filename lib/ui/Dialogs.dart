

import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';

import 'SnackBars.dart';

Widget createCategoryAlert(BuildContext context, String catId) {
  ThemeData _theme = Theme.of(context);
  final _formKey = GlobalKey<FormState>();
  final _addAlbumNameController = TextEditingController();
  final _addAlbumDescController = TextEditingController();


  return AlertDialog(
    insetPadding: EdgeInsets.all(10),
    actions: [
      InkResponse(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: CircleAvatar(
          child: Icon(Icons.close, color: _theme.errorColor),
          backgroundColor: Colors.transparent,
        ),
      ),
    ],
    title: Text("Album creation"),
    content: Container(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _theme.inputDecorationTheme.fillColor
                  ),
                  child: TextFormField(
                    maxLines: 1,
                    controller: _addAlbumNameController,
                    style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'album name',
                      hintStyle: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: _theme.disabledColor),
                    ),
                    validator: (value) {
                      if(value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _theme.inputDecorationTheme.fillColor
                  ),
                  child: TextFormField(
                    minLines: 1,
                    maxLines: 3,
                    controller: _addAlbumDescController,
                    style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'description (optional)',
                      hintStyle: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: _theme.disabledColor),
                    ),
                  ),
                ),
              ),
              Divider(
                thickness: 1,
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(_theme.accentColor),
                    ),
                    child: Text('Create album', style: TextStyle(fontSize: 16, color: Colors.white)),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        try {
                          var result = await addCategory(
                              _addAlbumNameController.text,
                              _addAlbumDescController.text, catId);
                          print('Created Album ${_addAlbumNameController
                              .text} : $result');
                          ScaffoldMessenger.of(context).showSnackBar(
                              albumAddedSnackBar(_addAlbumNameController.text)
                          );
                          _addAlbumNameController.text = "";
                          Navigator.of(context).pop();
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<String> confirmMoveCopyImage(
    BuildContext context, {
      Widget title,
      Widget content,
    }) async {
  final String confirm = await showDialog<String>(
    context: context,
    builder: (_) => WillPopScope(
      child: AlertDialog(
        title: title,
        content: (content != null) ? content : Text('Are you sure continue?'),
        actions: <Widget>[
          TextButton(
            child: Text('no', style: TextStyle(color: Theme.of(context).errorColor)),
            onPressed: () => Navigator.pop(context, 'cancel'),
          ),
          TextButton(
            child: Text('move', style: TextStyle(color: Theme.of(context).accentColor)),
            onPressed: () => Navigator.pop(context, 'move'),
          ),
          TextButton(
            child: Text('copy', style: TextStyle(color: Theme.of(context).accentColor)),
            onPressed: () => Navigator.pop(context, 'copy'),
          ),
        ],
      ),
      onWillPop: () async {
        Navigator.pop(context, 'cancel');
        return true;
      },
    ),
  );

  return (confirm != null) ? confirm : 'cancel';
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
  TextEditingController _addAlbumNameController;
  TextEditingController _addAlbumDescController;
  bool isPrivate = false;

  @override
  void initState() {
    super.initState();
    isPrivate = widget.privacy;
    _addAlbumNameController = TextEditingController(text: widget.catName);
    _addAlbumDescController = TextEditingController(text: widget.catDesc);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      actions: [
        InkResponse(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: CircleAvatar(
            child: Icon(Icons.close, color: _theme.errorColor),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
      title: Text("Album edition"),
      content: Container(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _theme.inputDecorationTheme.fillColor
                    ),
                    child: TextFormField(
                      maxLines: 1,
                      controller: _addAlbumNameController,
                      style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: 'album name',
                        hintStyle: TextStyle(fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: _theme.disabledColor),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _theme.inputDecorationTheme.fillColor
                    ),
                    child: TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      controller: _addAlbumDescController,
                      style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: 'description (optional)',
                        hintStyle: TextStyle(fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: _theme.disabledColor),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isPrivate,
                        onChanged: (value) {
                          setState(() {
                            isPrivate = value;
                          });
                        },
                      ),
                      Text('Private ?'),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1,
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                            _theme.accentColor),
                      ),
                      child: Text('Edit album',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          try {
                            var result = await editCategory(
                              widget.catId,
                              _addAlbumNameController.text,
                              _addAlbumDescController.text,
                              isPrivate
                            );
                            print('Edited Album ${_addAlbumNameController.text} : $result');
                            ScaffoldMessenger.of(context).showSnackBar(
                                albumEditedSnackBar(_addAlbumNameController.text)
                            );
                            _addAlbumNameController.text = "";
                            _addAlbumDescController.text = "";
                            Navigator.of(context).pop();
                          } catch (e) {
                            print(e);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}