import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piwigo_ng/components/buttons/animated_app_button.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../api/upload.dart';
import '../../models/tag_model.dart';
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
  final _listKey = GlobalKey<AnimatedListState>();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  final List<DropdownMenuItem<int>> _levelItems = [];
  final List<TagModel> _tags = [];
  int _privacyLevel = -1;
  bool _showFiles = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      privacyLevels.forEach((key, value) {
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

  Map<String, dynamic> get _imagesInfo {
    List<int> tagIds = _tags.map<int>((tag) {
      return tag.id;
    }).toList();
    return {
      'name': _nameController.text,
      'comment': _descController.text,
      'tag_ids': tagIds,
      'level': _privacyLevel,
    };
  }

  Future<void> _addFiles() async {
    try {
      final List<XFile>? pickerResult = await _picker.pickMultiImage();
      if (pickerResult != null && pickerResult.isNotEmpty) {
        setState(() {
          widget.imageData.addAll(pickerResult);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          widget.imageData.add(image);
        });
      }
    } catch (e) {
      debugPrint('Pick image error ${e.toString()}');
    }
  }

  Future<void> _onRemoveFile(int index) async {
    setState(() {
      widget.imageData.removeAt(index);
    });
  }

  Future<void> _onUpload() async {
    _btnController.start();
    var result = await uploadPhotos(widget.imageData, widget.category, info: _imagesInfo);
    if (!mounted) return;
    if (result.isEmpty) {
      _btnController.error();
      await Future.delayed(const Duration(milliseconds: 300));
      _btnController.reset();
    } else {
      _btnController.success();
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Scrollbar(
          thickness: 8,
          thumbVisibility: true,
          radius: Radius.circular(8),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                centerTitle: true,
                title: Text(appStrings.categoryUpload_images),
                actions: [
                  IconButton(
                    onPressed: _onUpload,
                    icon: const Icon(Icons.upload_file),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                    delegate: SliverChildListDelegate([
                  FormSection(
                    expanded: _showFiles,
                    onTapTitle: () => setState(() {
                      _showFiles = !_showFiles;
                    }),
                    title: appStrings.imageCount(widget.imageData.length),
                    actions: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _addFiles,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.add_to_photos, color: Theme.of(context).iconTheme.color),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _takePhoto,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.photo_camera_rounded, color: Theme.of(context).iconTheme.color),
                        ),
                      ),
                    ],
                    child: Builder(builder: (context) {
                      if (_showFiles) {
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 96,
                          ),
                          padding: const EdgeInsets.all(0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.imageData.length,
                          itemBuilder: (context, index) {
                            final File file = File(widget.imageData[index].path);
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    scale: 0.7,
                                    cacheHeight: 128,
                                    cacheWidth: 128,
                                    errorBuilder: (context, object, stacktrace) => Center(
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _onRemoveFile(index),
                                    child: CircleAvatar(
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                      radius: 12,
                                      child: Icon(Icons.remove_circle_outline, size: 20, color: Theme.of(context).errorColor),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return const SizedBox(width: double.infinity);
                    }),
                  ),
                  FormSection(
                    title: appStrings.editImageDetails_title,
                    child: AppField(
                      controller: _nameController,
                      margin: const EdgeInsets.symmetric(vertical: 0.0),
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      hint: appStrings.editImageDetails_titlePlaceholder,
                    ),
                  ),
                  FormSection(
                    title: appStrings.editImageDetails_description,
                    child: AppDescriptionField(
                      controller: _descController,
                      margin: const EdgeInsets.symmetric(vertical: 0.0),
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      hint: appStrings.editImageDetails_descriptionPlaceholder,
                      minLines: 5,
                      maxLines: 10,
                    ),
                  ), // Description
                  FormSection(
                    title: appStrings.tagsAdd_title,
                    actions: [
                      IconButton(
                        tooltip: appStrings.tagsTitle_selectOne,
                        onPressed: () {
                          // Todo: tags
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
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
                  FormSection(
                    title: appStrings.editImageDetails_privacyLevel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                      ),
                      child: DropdownButton<int>(
                        onTap: () {
                          final FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: _privacyLevel,
                        onChanged: (level) {
                          if (level == null) return;
                          setState(() {
                            _privacyLevel = level;
                          });
                        },
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: _levelItems,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: AnimatedAppButton(
                      controller: _btnController,
                      color: Theme.of(context).primaryColor,
                      disabled: widget.imageData.isEmpty,
                      onPressed: _onUpload,
                      child: Text(
                        widget.imageData.isEmpty ? appStrings.noImages : appStrings.imageUploadDetailsButton_title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ),
                ])),
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
