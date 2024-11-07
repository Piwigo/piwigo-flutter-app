import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:piwigo_ng/components/buttons/animated_piwigo_button.dart';
import 'package:piwigo_ng/components/cards/image_details_card.dart';
import 'package:piwigo_ng/components/cards/piwigo_chip.dart';
import 'package:piwigo_ng/components/dialogs/confirm_dialog.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/components/modals/move_or_copy_modal.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/components/modals/select_tags_modal.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/network/images.dart';
import 'package:piwigo_ng/network/upload.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/image_actions.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/resources.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:video_player/video_player.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key, required this.imageList, this.albumId}) : super(key: key);

  static const String routeName = '/upload';
  final List<XFile> imageList;
  final int? albumId;

  @override
  State<UploadPage> createState() => _UploadGalleryViewPage();
}

class _UploadGalleryViewPage extends State<UploadPage> with SingleTickerProviderStateMixin {
  static const double maxCarouselElementWidth = 300.0;
  static const double carouselHeight = 128.0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _authorController;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  final List<DropdownMenuItem<int?>> _levelItems = [];
  List<TagModel> _tags = [];
  List<XFile> _imageList = [];
  List<String> _imageExistList = [];
  int? _privacyLevel;
  late int _albumDestination;

  Future<void> _selectAlbum() async {
    await showPiwigoModal(
      context: context,
      builder: (_) => SelectMoveOrCopyModal(
        title: appStrings.selectCategory,
        subtitle: appStrings.selectCategory_select,
        isImage: true,
        onSelected: (album) async {
          if (!await showConfirmDialog(context,
          title: appStrings.selectCategory,
          message: appStrings.selectCategory_message(
            widget.imageList.length,
            album.name,
          ),
          )) return false;
          setState(() {
            _albumDestination = album.id;
          });
          return true;
        },
      ),
    );
  }

  @override
  void initState() {
    _imageList = List.from(widget.imageList);
    _authorController = TextEditingController(text: Preferences.getUploadAuthor);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        PrivacyLevel.values.forEach((privacy) {
          _levelItems.add(DropdownMenuItem<int?>(
            value: privacy.value,
            child: Tooltip(
              message: privacy.localization,
              child: Text(privacy.localization, overflow: TextOverflow.fade),
            ),
          ));
        });
      });
      if (widget.albumId != null) {
        _albumDestination = widget.albumId!;
      } else {
        _selectAlbum();
      }
      checkImageExist();
    });
  }

  Future<void> checkImageExist() async {
    List<File> files = await checkImagesNotExist(
      _imageList.map((e) => File(e.path)).toList(),
      returnExistFiles: true,
    );
    if (!mounted) return;
    setState(() {
      _imageExistList = files.map((e) => e.path).toList();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _addFiles() async {
    EasyLoading.show(
      status: appStrings.loadingHUD_label,
      indicator: CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: true,
    );
    if (!EasyLoading.isShow) return;
    EasyLoading.dismiss();
    List<XFile>? images = await onPickImages();
    if (!mounted) return;
    if (images != null && images.isNotEmpty) {
      setState(() {
        _imageList.addAll(images);
      });
      checkImageExist();
    }
  }

  Future<void> _takePhoto() async {
    XFile? image = await onTakePhoto(context);
    if (!mounted) return;
    if (image == null) return;
    setState(() {
      _imageList.add(image);
    });
  }

  Future<void> _onRemoveFile(int index) async {
    String path = _imageList[index].path;
    setState(() {
      _imageExistList.remove(path);
      _imageList.removeAt(index);
    });
  }

  Future<void> _onUpload() async {
    _btnController.start();
    List<int> tagIds = _tags.map<int>((tag) => tag.id).toList();
    List<XFile> filesToUpload = _imageList.where((e) => !_imageExistList.contains(e.path)).toList();
    var result = await uploadPhotos(filesToUpload, _albumDestination, info: {
      'name': _titleController.text,
      'comment': _descriptionController.text,
      'author': _authorController.text,
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
      appBar: AppBar(
        title: Text(appStrings.categoryUpload_images),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Builder(builder: (context) {
                if (_imageExistList.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.file_copy),
                        SizedBox(width: 8.0),
                        Flexible(
                          child: Text(
                            appStrings.settings_autoUploadDuplicateInfo,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox(width: double.infinity);
              }),
            ),
            FormSection(
              title: appStrings.imageUploadDetailsView_title,
              child: _carousel,
              titlePadding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 24.0,
              ),
              actions: [
                IconButton(
                  onPressed: _takePhoto,
                  icon: Icon(Icons.add_a_photo),
                ),
                IconButton(
                  onPressed: _addFiles,
                  icon: Icon(Icons.add_photo_alternate),
                ),
              ],
            ),
            _form,
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: AnimatedPiwigoButton(
                controller: _btnController,
                color: Theme.of(context).primaryColor,
                disabled: _imageList.isEmpty,
                onPressed: _onUpload,
                child: Text(
                  _imageList.isEmpty ? appStrings.noImages : appStrings.imageUploadDetailsButton_title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _form {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FormSection(
          title: appStrings.editImageDetails_title,
          child: AppField(
            controller: _titleController,
            hint: appStrings.editImageDetails_titlePlaceholder,
          ),
        ), // title
        FormSection(
          title: appStrings.editImageDetails_author,
          child: AppField(
            controller: _authorController,
            hint: appStrings.settings_defaultAuthorPlaceholder,
          ),
        ), // author
        FormSection(
          title: appStrings.editImageDetails_description,
          child: AppField(
            controller: _descriptionController,
            hint: appStrings.editImageDetails_descriptionPlaceholder,
            minLines: 5,
            maxLines: 10,
          ),
        ), // description
        FormSection(
          title: appStrings.editImageDetails_privacyLevel,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            child: DropdownButton<int?>(
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
                setState(() {
                  _privacyLevel = level;
                });
              },
              style: Theme.of(context).textTheme.bodyMedium,
              items: _levelItems,
            ),
          ),
        ), // privacy
        FormSection(
          title: appStrings.tags,
          onTapTitle: () {
            showSelectTagsModal(context, _tags).then((value) {
              if (value is! List<TagModel>) return;
              setState(() {
                _tags = value;
              });
            });
          },
          actions: [
            const Icon(Icons.edit),
          ],
          child: Wrap(
            spacing: 8.0,
            runSpacing: .0,
            children: List.generate(_tags.length, (index) {
              TagModel tag = _tags[index];
              return PiwigoChip(
                label: tag.name,
                backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
              );
            }),
          ),
        ), // tags
      ],
    );
  }

  Widget get _carousel {
    return SizedBox(
      height: carouselHeight,
      child: OrientationBuilder(builder: (context, orientation) {
        return PageView.builder(
          controller: PageController(
            viewportFraction: min(
              maxCarouselElementWidth / MediaQuery.of(context).size.width,
              0.9,
            ),
          ),
          padEnds: false,
          itemCount: _imageList.length,
          itemBuilder: (context, index) {
            XFile file = _imageList[index];
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 8.0 : 0.0,
                right: index == _imageList.length - 1 ? 8.0 : 0.0,
              ),
              child: Builder(builder: (context) {
                List<String>? mimeType = mime(file.path.split('/').last)?.split('/');
                if (mimeType?.first == 'video') {
                  return LocalVideoDetailsCard(
                    video: File(file.path),
                    onRemove: () => _onRemoveFile(index),
                    isDuplicate: _imageExistList.contains(file.path),
                  );
                }
                return LocalImageDetailsCard(
                  image: File(file.path),
                  onRemove: () => _onRemoveFile(index),
                  isDuplicate: _imageExistList.contains(file.path),
                );
              }),
            );
          },
        );
      }),
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
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.black.withOpacity(0.7)),
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
