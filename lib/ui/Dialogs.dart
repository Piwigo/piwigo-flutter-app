

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/api/TagAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';

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
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    _isPrivate = widget.privacy;
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
                        value: _isPrivate,
                        onChanged: (value) {
                          setState(() {
                            _isPrivate = value;
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
                              _isPrivate
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


class EditImageSelectionDialog extends StatefulWidget {
  final int catId;
  final List<dynamic> images;

  const EditImageSelectionDialog({Key key, this.catId, this.images}) : super(key: key);

  @override
  _EditImageSelectionDialogState createState() => _EditImageSelectionDialogState();
}
class _EditImageSelectionDialogState extends State<EditImageSelectionDialog> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _nameControllers = [];
  List<TextEditingController> _descControllers = [];
  List<DropdownMenuItem<int>> _levelItems = [];
  List<dynamic> _tags = [];
  int _page = 0;
  int _privacyLevel = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    widget.images.forEach((image) {
      _nameControllers.add(TextEditingController(text: image['name']));
      _descControllers.add(TextEditingController(text: image['comment']));
    });

    Constants.privacyLevels.forEach((key, value) {
      _levelItems.add(DropdownMenuItem<int>(
        value: key,
        child: Tooltip(
          message: value,
          child: Text(value, overflow: TextOverflow.fade),
        ),
      ));
    });
  }

  bool isNameEmpty() {
    for(var controller in _nameControllers) {
      if(controller.text == "" || controller.text == null) {
        return true;
      }
    }
    return false;
  }

  void applyNameToAll(String name) {
    for(var controller in _nameControllers) {
      controller.text = name;
    }
  }

  void applyDescToAll(String desc) {
    for(var controller in _descControllers) {
      controller.text = desc;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Edit selection", overflow: TextOverflow.ellipsis),
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
      ),
      content: Container(
        width: screenSize.width*3/4,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  height: 160,
                  child: PageView(
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
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 150,
                                    width: 150,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: _theme.inputDecorationTheme.fillColor,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(image['derivatives']['square']['url'], fit: BoxFit.cover),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 130,
                                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
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
                                          Text('${image['file']}', style: _theme.textTheme.bodyText2, overflow: TextOverflow.fade),
                                          Text('${image['date_creation']}', style: _theme.textTheme.bodyText2, overflow: TextOverflow.fade),
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
                                  if(widget.images.length == 1) {
                                    Navigator.of(context).pop();
                                  } else {
                                    int page = _page;
                                    if(_page == widget.images.length-1) {
                                      _page--;
                                    }
                                    setState(() {
                                      widget.images.removeAt(page);
                                      _nameControllers.removeAt(page);
                                      _descControllers.removeAt(page);
                                    });
                                  }
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
                            /*
                            Positioned(
                                top: -25,
                                right: -15,
                                child: InkWell(
                                  onTap: () {
                                    print('change image name');
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(3),
                                    child: Stack(
                                      alignment: Alignment.bottomLeft,
                                      children: [
                                        Icon(Icons.edit_sharp, color: _theme.scaffoldBackgroundColor, size: 55),
                                        Positioned(
                                          bottom: 6,
                                          left: 6,
                                          child: Icon(Icons.edit, color: _theme.iconTheme.color),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ),
                             */
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _theme.inputDecorationTheme.fillColor
                          ),
                          child: TextFormField(
                            maxLines: 1,
                            controller: _nameControllers[_page],
                            style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              hintText: 'image name',
                              hintStyle: TextStyle(fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: _theme.disabledColor),
                            ),
                            validator: (value) {
                              if (isNameEmpty()) {
                                return 'An image name is empty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Apply all',
                        onPressed: () async {
                          if(await confirm(context,
                            title: Text('Confirm'),
                            content: Text('Apply name ${_nameControllers[_page].text} to all files ?', softWrap: true, maxLines: 3),
                            textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                            textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
                          )) {
                            setState(() {
                              applyNameToAll(_nameControllers[_page].text);
                            });
                          }
                        },
                        icon: Icon(Icons.copy),
                      ),
                    ],
                  ),
                ), // Name
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _theme.inputDecorationTheme.fillColor
                          ),
                          child: TextFormField(
                            minLines: 1,
                            maxLines: 3,
                            controller: _descControllers[_page],
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
                      IconButton(
                        tooltip: 'Apply all',
                        onPressed: () async {
                          if(await confirm(context,
                            title: Text('Confirm'),
                            content: Text('Apply description ${_descControllers[_page].text} to all files ?', softWrap: true, maxLines: 3),
                            textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                            textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
                          )) {
                            setState(() {
                              applyDescToAll(_descControllers[_page].text);
                            });
                          }
                        },
                        icon: Icon(Icons.copy),
                      ),
                    ],
                  ),
                ), // Description
                Divider(
                  thickness: 1,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text('Who can see this photo', style: _theme.textTheme.bodyText1),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
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
                ), // Privacy
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text('Append Tags', style: _theme.textTheme.bodyText1),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: 50,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x60000000),
                              ),
                              BoxShadow(
                                color: _theme.scaffoldBackgroundColor,
                                blurRadius: 3.0,
                                spreadRadius: -1.0,
                                offset: Offset(0.0, 3.0),
                              )
                            ],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Wrap(
                                direction: Axis.horizontal,
                                spacing: 5,
                                runSpacing: 5,
                                children: _tags.map<Widget>((tag) {
                                  return tagItem(tag);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Select tags',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SelectTagDialog(
                                  _tags,
                                      (tags) {
                                    setState(() {
                                      _tags = tags;
                                    });
                                  });
                            }
                          );
                        },
                        icon: Icon(Icons.add_circle_outline),
                      ),
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
                      child: _isLoading? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Text('Confirm',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await editImages(
                              widget.images.map<Map<String,dynamic>>((image) {
                                int index = widget.images.indexOf(image);
                                return {
                                  'id': image['id'],
                                  'name': _nameControllers[index].text,
                                  'desc': _descControllers[index].text,
                                };
                              }).toList(),
                              _tags.map<int>((tag) {
                                return int.parse(tag['id']);
                              }).toList(),
                              _privacyLevel
                            );

                            Navigator.of(context).pop();
                          } catch (e) {
                            print(e);
                            setState(() {
                              _isLoading = false;
                            });
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

  Widget tagItem(dynamic tag) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x60000000),
            blurRadius: 3.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 3.0),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('${tag['name']}'),
          IconButton(
            onPressed: () async {
              if(await confirm(
                context,
                title: Text('Confirm'),
                content: Text('Remove tag ${tag['name']} ?', softWrap: true, maxLines: 3),
                textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
              )) {
                setState(() {
                  _tags.remove(tag);
                });
              }
            },
            icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).errorColor),
          ),
        ],
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
    _selectedTags = widget.selectedTags;
  }

  bool isSelected(dynamic tag) {
    for(var selectedTag in _selectedTags) {
      if(tag['id'] == selectedTag['id']) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Select Tags"),
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
      ),
      content: FutureBuilder(
        future: getAdminTags(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            var tags = snapshot.data;
            tags.removeWhere((tag) {
              return isSelected(tag);
            });
            return Container(
              width: screenSize.width*3/4-20,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('All tags', style: _theme.textTheme.bodyText1),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return createTagAlert(context);
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
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 50,
                        maxHeight: screenSize.width/2,
                        minWidth: double.infinity,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x60000000),
                          ),
                          BoxShadow(
                            color: _theme.scaffoldBackgroundColor,
                            blurRadius: 3.0,
                            spreadRadius: -1.0,
                            offset: Offset(0.0, 3.0),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            direction: Axis.horizontal,
                            children: tags.map<Widget>((tag) {
                              return Wrap(
                                direction: Axis.vertical,
                                children: [tagItem(tag, Icon(Icons.add_circle_outline, color: Colors.green), onTap: () {
                                  setState(() {
                                    if(!isSelected(tag)) _selectedTags.add(tag);
                                  });
                                })],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ), // Tag list
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(5),
                      child: Text('Selected tags', style: _theme.textTheme.bodyText1),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 50,
                        minWidth: double.infinity,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x60000000),
                          ),
                          BoxShadow(
                            color: _theme.scaffoldBackgroundColor,
                            blurRadius: 3.0,
                            spreadRadius: -1.0,
                            offset: Offset(0.0, 3.0),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(5),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Wrap(
                            spacing: 5,
                            direction: Axis.horizontal,
                            children: _selectedTags.map<Widget>((tag) {
                              return tagItem(tag, Icon(Icons.remove_circle_outline, color: _theme.errorColor), onTap: () {
                                setState(() {
                                  if(isSelected(tag)) _selectedTags.remove(tag);
                                });
                              });
                            }).toList(),
                          ),
                        ),
                      ),
                    ), // Selected tags
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
                          child: _isLoading?
                            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) :
                            Text('Confirm', style: TextStyle(fontSize: 16, color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            widget.onConfirm(_selectedTags);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              constraints: BoxConstraints(
                maxWidth: screenSize.width*3/4,
                maxHeight: screenSize.width*3/4,
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

  Widget tagItem(dynamic tag, Icon icon, {Function() onTap}) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x60000000),
            blurRadius: 3.0,
            spreadRadius: 0.0,
            offset: Offset(0.0, 3.0),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('${tag['name']}'),
          IconButton(
            onPressed: () async {
              onTap();
            },
            icon: icon,
          ),
        ],
      ),
    );
  }
}

Widget createTagAlert(BuildContext context) {
  ThemeData _theme = Theme.of(context);
  final _formKey = GlobalKey<FormState>();
  final _addTagNameController = TextEditingController();

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
    title: Text("Create new tag"),
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
                    controller: _addTagNameController,
                    style: TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'tag name',
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
                    child: Text('Create tag', style: TextStyle(fontSize: 16, color: Colors.white)),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        try {
                          var result = await createTag(
                            _addTagNameController.text,
                          );
                          print('Create tag : $result');

                          _addTagNameController.text = "";
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