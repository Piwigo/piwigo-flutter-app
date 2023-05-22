import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/components/buttons/app_button.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';

import '../../models/tag_model.dart';
import '../../services/uploader.dart';
import '../../utils/localizations.dart';

class UploadViewPage extends StatefulWidget {
  const UploadViewPage({Key? key, required this.imageData, required this.category}) : super(key: key);

  static const String routeName = '/upload';
  final List<XFile> imageData;
  final String category;

  @override
  State<UploadViewPage> createState() => _UploadGalleryViewPage();
}

class _UploadGalleryViewPage extends State<UploadViewPage> {
  final _formKey = GlobalKey<FormState>();
  final _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<DropdownMenuItem<int>> _levelItems = [];
  final List<TagModel> _tags = [];
  int _page = 0;
  int _privacyLevel = -1;
  bool _isLoading = false;

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
    return (MediaQuery.of(context).size.width / 200).ceil();
  }

  Map<String, dynamic> getImagesInfo() {
    List<int> tagIds = _tags.map<int>((tag) {
      return tag.id;
    }).toList();
    return {'name': _nameController.text, 'comment': _descController.text, 'tag_ids': tagIds, 'level': _privacyLevel};
  }

  Future<void> addFiles() async {
    setState(() {
      _isFilesLoading = true;
    });
    try {
      List<XFile>? pickerResult = await ImagePicker().pickMultiImage();
      if (pickerResult != null && pickerResult.isNotEmpty) {
        setState(() {
          widget.imageData.addAll(pickerResult);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      _isFilesLoading = false;
    });
  }

  Future<void> takePhoto() async {
    setState(() {
      _isFilesLoading = true;
    });
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          widget.imageData.add(image);
        });
      }
    } catch (e) {
      debugPrint('Pick image error ${e.toString()}');
    }
    setState(() {
      _isFilesLoading = false;
    });
  }

  Future<void> onRemoveFile() async {
    int page = _page;
    if (_page == widget.imageData.length - 1) {
      _page--;
    }
    setState(() {
      widget.imageData.removeAt(page);
    });
  }

  Future<void> onUpload() async {
    setState(() {
      _isLoading = true;
    });
    uploadPhotos(widget.imageData, widget.category, info: getImagesInfo());
    if (mounted) {
      setState(() {
        _isLoading = false;
        widget.imageData.clear();
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        title: Text(appStrings.categoryUpload_images),
        actions: [
          IconButton(
            onPressed: onUpload,
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    appStrings.imageCount(widget.imageData.length),
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText2!.color),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: addFiles,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Colors.white,
                          ),
                          child: Icon(Icons.add_to_photos, color: Theme.of(context).iconTheme.color),
                        ),
                        ElevatedButton(
                          onPressed: takePhoto,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Colors.white,
                          ),
                          child: Icon(Icons.photo_camera_rounded, color: Theme.of(context).iconTheme.color),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _isFilesLoading ? const LinearProgressIndicator() : const SizedBox(),
              const Divider(
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            appStrings.imageUploadDetailsEdit_title,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(appStrings.editImageDetails_title, style: Theme.of(context).textTheme.headline5),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15),
                        child: AppField(
                          controller: _nameController,
                          hint: appStrings.editImageDetails_titlePlaceholder,
                        ),
                      ), // Name
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(appStrings.editImageDetails_description, style: Theme.of(context).textTheme.headline5),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: AppDescriptionField(
                          controller: _descController,
                          hint: appStrings.editImageDetails_descriptionPlaceholder,
                          minLines: 5,
                          maxLines: 10,
                          padding: const EdgeInsets.all(10),
                        ),
                      ), // Description
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appStrings.tagsAdd_title, style: Theme.of(context).textTheme.headline5),
                          IconButton(
                            tooltip: appStrings.tagsTitle_selectOne,
                            onPressed: () {
                              // Todo: tags
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedList(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            key: _listKey,
                            initialItemCount: _tags.length,
                            itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                              if (_tags.isEmpty) return const SizedBox();
                              if (index == _tags.length - 1) {
                                return tagItem(
                                  _tags[index],
                                  animation,
                                );
                              }
                              return tagItem(
                                _tags[index],
                                animation,
                                border: Border(bottom: BorderSide(color: Theme.of(context).scaffoldBackgroundColor)),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(appStrings.editImageDetails_privacyLevel, style: Theme.of(context).textTheme.headline5),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10), color: Theme.of(context).inputDecorationTheme.fillColor),
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
                              if (level == null) return;
                              setState(() {
                                _privacyLevel = level;
                              });
                            },
                            style: const TextStyle(fontSize: 14, color: Color(0xff5c5c5c)),
                            items: _levelItems,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(
                margin: const EdgeInsets.all(10),
                onPressed: onUpload,
                child: _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Text(appStrings.imageUploadDetailsButton_title, style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tagItem(TagModel tag, Animation<double> animation, {Border? border}) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            border: border ?? const Border.fromBorderSide(BorderSide.none),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tag.name, style: Theme.of(context).textTheme.subtitle1),
              InkWell(
                onTap: () async {
                  _listKey.currentState?.removeItem(_tags.indexOf(tag), (context, animation) => tagItem(tag, animation));
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
