import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/TagAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/model/TagModel.dart';
import 'package:piwigo_ng/views/components/buttons.dart';
import 'package:piwigo_ng/views/components/textfields.dart';

import 'package:piwigo_ng/views/components/snackbars.dart';
import 'piwigo_dialog.dart';



class SelectTagDialog extends StatefulWidget {
  final Function(List<TagModel>) onConfirm;
  final List<TagModel> selectedTags;

  const SelectTagDialog(this.selectedTags, this.onConfirm, {Key key}) : super(key: key);

  @override
  _SelectTagDialogState createState() => _SelectTagDialogState();
}
class _SelectTagDialogState extends State<SelectTagDialog> {
  List<TagModel> _selectedTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTags.addAll(widget.selectedTags);
    _sortTagList(_selectedTags);
  }

  void _sortTagList(List<TagModel> list) {
    list.sort((a, b) => a.compareTo(b));
  }

  void _updateLists(List<TagModel> allTags) {
    _sortTagList(allTags);
    _sortTagList(_selectedTags);
  }

  bool _isSelected(TagModel tag) {
    for(var selectedTag in _selectedTags) {
      if(tag.id == selectedTag.id) {
        return true;
      }
    }
    return false;
  }

  void _onSelectTags() {
    setState(() {
      _isLoading = true;
    });
    widget.onConfirm(_selectedTags);
    Navigator.of(context).pop();
  }

  List<TagModel> _tagListFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TagModel.fromJson(json)).toList();
  }

  _isSelectedEndTag(TagModel tag) {
    return _isSelected(tag) && (tag.id == _selectedTags.last.id);
  }

  _isUnselectedEndTag(TagModel tag, List<TagModel> tags) {
    List<TagModel> unselectedTags = tags.where((e) => !_selectedTags.contains(e)).toList();
    return !_isSelected(tag) && (tag.id == unselectedTags.last.id);
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
            List<TagModel> tags = _tagListFromJson(snapshot.data["result"]['tags']);
            _updateLists(tags);
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
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tags.length,
                        itemBuilder: (BuildContext context, int index) {
                          TagModel tag = tags[index];
                          return TagItem(tag,
                            isExpanded: _isSelected(tag),
                            isEnd: _isSelectedEndTag(tag),
                            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                            onTap: () {
                              setState(() {
                                _selectedTags.removeWhere((e) => e.id == tag.id);
                                _updateLists(tags);
                              });
                            },
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
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tags.length,
                        itemBuilder: (BuildContext context, int index) {
                          TagModel tag = tags[index];
                          return TagItem(tag,
                            isExpanded: !_isSelected(tag),
                            isEnd: _isUnselectedEndTag(tag, tags),
                            icon: Icon(Icons.add_circle_outline, color: Colors.green),
                            onTap: () {
                              setState(() {
                                _selectedTags.add(tag);
                                _updateLists(tags);
                              });
                            },
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
                        onPressed: _onSelectTags,
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

class TagItem extends StatefulWidget {
  const TagItem(this.tag, {Key key, this.onTap, this.icon, this.isExpanded = true, this.isEnd = false}) : super(key: key);

  final TagModel tag;
  final Icon icon;
  final bool isExpanded;
  final bool isEnd;
  final Function() onTap;

  @override
  _TagItemState createState() => _TagItemState();
}
class _TagItemState extends State<TagItem> with SingleTickerProviderStateMixin {
  bool _isExpanded;
  AnimationController _controller;
  Animation<double> _heightFactor;

  @override
  initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));
    _isExpanded = widget.isExpanded;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TagItem oldWidget) {
    if (widget.isExpanded != oldWidget.isExpanded) {
      setState(() {
        _isExpanded = widget.isExpanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse().then<void>((void value) {
            if (!mounted) return;
            setState(() {});
          });
        }
      });
    } else if (widget.tag != oldWidget.tag) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildTagItem() {
    return InkWell(
      onTap: widget.onTap,
      child: Column(
        children: [
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.tag.name}',
                    style: Theme.of(context).textTheme.subtitle1
                ),
                widget.icon ?? SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    final bool closed =
        (!_isExpanded || !widget.isExpanded) && _controller.isDismissed;

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (BuildContext context, Widget child) {
        return Column(
          children: [
            ClipRect(
              child: Align(
                heightFactor: _heightFactor.value,
                child: child,
              ),
            ),
            _isExpanded && !widget.isEnd ? Divider(
              indent: 10.0,
              endIndent: 0.0,
              height: 1.0,
            ) : SizedBox(),
          ],
        );
      },
      child: closed ? null : _buildTagItem(),
    );
  }
}
