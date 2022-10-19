import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:piwigo_ng/components/buttons/animated_app_button.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:piwigo_ng/utils/resources.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:video_player/video_player.dart';

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
  final _tagListKey = GlobalKey<AnimatedListState>();
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

  Future<void> _addFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media,
      );
      if (result == null) return;
      final List<XFile> images = result.files.map<XFile>((e) {
        return XFile(e.path!, name: e.name, bytes: e.bytes);
      }).toList();
      if (images.isNotEmpty) {
        setState(() {
          widget.imageData.addAll(images);
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

  Future<void> _takeVideo() async {
    try {
      final XFile? image = await _picker.pickVideo(source: ImageSource.camera);
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
    List<int> tagIds = _tags.map<int>((tag) => tag.id).toList();
    var result = await uploadPhotos(widget.imageData, widget.category, info: {
      'name': _nameController.text,
      'comment': _descController.text,
      'tag_ids': tagIds,
      'level': _privacyLevel,
    });
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
                          child: Icon(Icons.add_photo_alternate),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _takePhoto,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.photo_camera_rounded),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _takeVideo,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.video_camera_back),
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
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Builder(builder: (context) {
                                      List<String>? mimeType = mime(file.path.split('/').last)?.split('/');
                                      if (mimeType?.first == 'image') {
                                        return Image.file(
                                          file,
                                          fit: BoxFit.cover,
                                          scale: 0.7,
                                          cacheHeight: 128,
                                          cacheWidth: 128,
                                          errorBuilder: (context, object, stacktrace) => Center(
                                            child: Icon(Icons.image_not_supported),
                                          ),
                                        );
                                      }
                                      if (mimeType?.first == 'video') {
                                        return VideoUploadItem(
                                          path: file.path,
                                        );
                                      }
                                      return const Center(
                                        child: Icon(Icons.image_not_supported),
                                      );
                                    }),
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
                        key: _tagListKey,
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
                  _tagListKey.currentState?.removeItem(_tags.indexOf(tag), (context, animation) => tagItem(tag, animation));
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

class VideoUploadItem extends StatefulWidget {
  const VideoUploadItem({Key? key, required this.path}) : super(key: key);

  final String path;

  @override
  State<VideoUploadItem> createState() => _VideoUploadItemState();
}

class _VideoUploadItemState extends State<VideoUploadItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      File(widget.path),
      videoPlayerOptions: VideoPlayerOptions(),
    )..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _duration {
    final Duration duration = _controller.value.duration;
    int hours = duration.inHours;
    int minutes = (duration - Duration(hours: hours)).inMinutes;
    int seconds = (duration - Duration(hours: hours) - Duration(minutes: minutes)).inSeconds;
    return '${hours > 0 ? '$hours:' : ''}${minutes < 10 ? '0$minutes' : '$minutes'}:${seconds < 10 ? '0$seconds' : '$seconds'}';
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.hasError) {
      return Center(
        child: Icon(Icons.image_not_supported),
      );
    }
    if (!_controller.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.black.withOpacity(0.7)),
              child: Text(
                _duration,
                style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    });
  }
}
