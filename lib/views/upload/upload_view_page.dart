import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:piwigo_ng/components/buttons/animated_piwigo_button.dart';
import 'package:piwigo_ng/components/cards/tag_chip.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/components/modals/add_tags_modal.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:piwigo_ng/models/tag_model.dart';
import 'package:piwigo_ng/network/images.dart';
import 'package:piwigo_ng/network/upload.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/image_actions.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/resources.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:video_player/video_player.dart';

class UploadViewPage extends StatefulWidget {
  const UploadViewPage(
      {Key? key, required this.imageList, required this.albumId})
      : super(key: key);

  static const String routeName = '/upload';
  final List<XFile> imageList;
  final int albumId;

  @override
  State<UploadViewPage> createState() => _UploadGalleryViewPage();
}

class _UploadGalleryViewPage extends State<UploadViewPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late final TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _authorController;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  final List<DropdownMenuItem<int?>> _levelItems = [];
  List<TagModel> _tags = [];
  List<XFile> _imageList = [];
  List<String> _imageExistList = [];
  int? _privacyLevel;

  @override
  void initState() {
    _imageList = List.from(widget.imageList);
    _authorController =
        TextEditingController(text: Preferences.getUploadAuthor);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
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
      checkImageExist();
    });
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
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
    _tabController.dispose();
    super.dispose();
  }

  BorderRadiusGeometry _imageGridBorder(int index) {
    Radius topLeft = Radius.circular(index == 0 ? 10.0 : 5.0);
    Radius topRight = Radius.circular(
        _imageList.length < Settings.getImageCrossAxisCount(context)
            ? 10.0
            : 5.0);
    Radius bottomRight =
        Radius.circular(index == _imageList.length - 1 ? 10.0 : 5.0);
    Radius bottomLeft = Radius.circular(index ==
            _imageList.length -
                (_imageList.length % Settings.getImageCrossAxisCount(context) ==
                        0
                    ? Settings.getImageCrossAxisCount(context)
                    : _imageList.length %
                        Settings.getImageCrossAxisCount(context))
        ? 10.0
        : 5.0);

    return BorderRadius.circular(5.0).copyWith(
      topLeft: topLeft,
      topRight: topRight,
      bottomRight: bottomRight,
      bottomLeft: bottomLeft,
    );
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

  void _onDeselectTag(TagModel tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _onUpload() async {
    _btnController.start();
    List<int> tagIds = _tags.map<int>((tag) => tag.id).toList();
    List<XFile> filesToUpload =
        _imageList.where((e) => !_imageExistList.contains(e.path)).toList();
    var result = await uploadPhotos(filesToUpload, widget.albumId, info: {
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

  void _checkMemory() {
    ImageCache imageCache = PaintingBinding.instance.imageCache;
    if (imageCache.liveImageCount >= Settings.maxCacheLiveImages) {
      imageCache.clear();
      imageCache.clearLiveImages();
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
                if (_imageExistList.length != _imageList.length) {
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
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                color: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 0.0,
                indicator: ShapeDecoration(
                  shape: StadiumBorder(),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: appStrings.imageUploadDetailsButton_title),
                  Tab(text: appStrings.imageUploadDetailsView_title),
                ],
              ),
            ),
            [_form, _imageGrid][_tabController.index],
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
                  _imageList.isEmpty
                      ? appStrings.noImages
                      : appStrings.imageUploadDetailsButton_title,
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
          title: appStrings.tagsAdd_title,
          onTapTitle: () {
            showPiwigoModal<List<TagModel>>(
              context: context,
              builder: (_) => AddTagsModal(
                selectedTags: _tags,
              ),
            ).then((value) {
              if (value is! List<TagModel>) return;
              setState(() {
                _tags = value;
              });
            });
          },
          actions: [
            const Icon(Icons.add_circle),
          ],
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List.generate(_tags.length, (index) {
              TagModel tag = _tags[index];
              return TagChip(
                tag: tag,
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.error,
                ),
                onTap: () => _onDeselectTag(tag),
              );
            }),
          ),
        ), // tags
      ],
    );
  }

  Widget get _imageGrid {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FormSection(
          title: appStrings.imageCount(_imageList.length),
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
          ],
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Settings.getImageCrossAxisCount(context),
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            addAutomaticKeepAlives: false,
            cacheExtent: 0,
            itemCount: _imageList.length,
            itemBuilder: (context, index) {
              File file = File(_imageList[index].path);
              // File file = File(_imageList.first.path);
              return _buildImageCard(file, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(File file, int index) {
    _checkMemory();
    return Stack(
      children: [
        Positioned(
          top: 4.0,
          right: 4.0,
          left: 4.0,
          bottom: 4.0,
          child: ClipRRect(
            borderRadius: _imageGridBorder(index),
            child: Stack(
              fit: StackFit.expand,
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  List<String>? mimeType =
                      mime(file.path.split('/').last)?.split('/');
                  if (mimeType?.first == 'image') {
                    double? cacheWidth = constraints.maxWidth.isInfinite
                        ? constraints.maxWidth
                        : null;
                    double? cacheHeight = constraints.maxHeight.isInfinite
                        ? constraints.maxHeight
                        : null;
                    return Image.file(
                      file,
                      fit: BoxFit.cover,
                      cacheWidth: cacheWidth?.floor(),
                      cacheHeight: cacheHeight?.floor(),
                      width: cacheWidth,
                      height: cacheHeight,
                      filterQuality: FilterQuality.low,
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
                if (_imageExistList.contains(file.path))
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                    ),
                    child: Icon(Icons.file_copy),
                  ),
              ],
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
              child: Icon(Icons.remove_circle_outline,
                  size: 20, color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
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
    int seconds =
        (duration - Duration(hours: hours) - Duration(minutes: minutes))
            .inSeconds;
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
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.black.withOpacity(0.7)),
              child: Text(
                _duration,
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    });
  }
}
