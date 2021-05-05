

import 'package:flutter/material.dart';
import 'package:poc_piwigo/api/CategoryAPI.dart';

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
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 250,
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
      ],
    ),
  );
}