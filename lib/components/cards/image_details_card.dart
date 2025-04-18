import 'dart:io';
import 'dart:ui' as ui show Image;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as path;
import 'package:piwigo_ng/components/app_image_display.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/locale_provider.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/resources.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ImageDetailsCard extends StatelessWidget {
  const ImageDetailsCard({Key? key, required this.image, this.onRemove}) : super(key: key);

  final ImageModel image;
  final Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _imageThumbnail(context),
                Expanded(
                  child: _imageDetails(context),
                ),
              ],
            ),
          ),
        ),
        if (onRemove != null) _removeButton(context),
      ],
    );
  }

  Widget _imageThumbnail(context) => Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).cardColor,
        ),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Builder(builder: (context) {
              final String? imageUrl = image.getDerivativeFromString(Preferences.getImageThumbnailSize)?.url;
              return ImageNetworkDisplay(
                imageUrl: imageUrl,
              );
            }),
          ),
        ),
      );

  Widget _imageDetails(context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(10.0)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "${image.width}x${image.height} pixels",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    image.file.replaceAll('', '\u200B').split(path.extension(image.file)).first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  path.extension(image.file),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (image.dateAvailable != null)
            Builder(builder: (context) {
              LocaleNotifier localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
              String date =
                  DateFormat.yMMMMd(localeNotifier.locale.languageCode).format(DateTime.parse(image.dateAvailable!));
              String time =
                  DateFormat.Hms(localeNotifier.locale.languageCode).format(DateTime.parse(image.dateAvailable!));
              return AutoSizeText(
                "$date $time",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              );
            }),
        ],
      ),
    );
  }

  Widget _removeButton(context) => Positioned(
        bottom: 0.0,
        right: 16.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onRemove,
          child: Container(
            padding: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
            ),
            child: Icon(Icons.remove_circle_outline),
          ),
        ),
      );
}

class LocalImageDetailsCard extends StatefulWidget {
  const LocalImageDetailsCard({Key? key, required this.image, this.onRemove, this.isDuplicate = false})
      : super(key: key);

  final File image;
  final Function()? onRemove;
  final bool isDuplicate;

  @override
  State<LocalImageDetailsCard> createState() => _LocalImageDetailsCardState();
}

class _LocalImageDetailsCardState extends State<LocalImageDetailsCard> {
  late final Future<ui.Image> _detailsFuture;

  @override
  void initState() {
    _detailsFuture = decodeImageFromList(widget.image.readAsBytesSync());
    super.initState();
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _imageThumbnail(context),
              Expanded(
                child: _imageDetails(context),
              ),
            ],
          ),
        ),
        _removeButton(context),
      ],
    );
  }

  Widget _imageThumbnail(context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).cardColor,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              LayoutBuilder(builder: (context, constraints) {
                List<String>? mimeType = mime(widget.image.path.split('/').last)?.split('/');

                if (mimeType?.first == 'image') {
                  _checkMemory();
                  double? cacheWidth = constraints.maxWidth.isInfinite ? constraints.maxWidth : null;
                  double? cacheHeight = constraints.maxHeight.isInfinite ? constraints.maxHeight : null;
                  return Image.file(
                    widget.image,
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
                return const Center(
                  child: Icon(Icons.image_not_supported),
                );
              }),
              if (widget.isDuplicate)
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
    );
  }

  Widget _imageDetails(context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(10.0)),
        color: Theme.of(context).cardColor,
      ),
      child: FutureBuilder<ui.Image>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ui.Image decodedImage = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "${decodedImage.width}x${decodedImage.height} pixels",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ExtendedText(
                    widget.image.path.replaceAll('', '\u200B'),
                    maxLines: 1,
                    overflowWidget: TextOverflowWidget(
                      position: TextOverflowPosition.start,
                      child: Text("..."),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Icon(Icons.error),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _removeButton(context) {
    return Positioned(
      bottom: 0.0,
      right: 16.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onRemove,
        child: Container(
          padding: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
          ),
          child: Icon(Icons.remove_circle_outline),
        ),
      ),
    );
  }
}

class LocalVideoDetailsCard extends StatefulWidget {
  const LocalVideoDetailsCard({Key? key, required this.video, this.onRemove, this.isDuplicate = false})
      : super(key: key);

  final File video;
  final Function()? onRemove;
  final bool isDuplicate;

  @override
  State<LocalVideoDetailsCard> createState() => _LocalVideoDetailsCardState();
}

class _LocalVideoDetailsCardState extends State<LocalVideoDetailsCard> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.file(
      File(widget.video.path),
      videoPlayerOptions: VideoPlayerOptions(),
    )..initialize().then((_) => setState(() {}));
    super.initState();
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _videoThumbnail(context),
              Expanded(
                child: _videoDetails(context),
              ),
            ],
          ),
        ),
        _removeButton(context),
      ],
    );
  }

  Widget _videoThumbnail(context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).cardColor,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              LayoutBuilder(builder: (context, constraints) {
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
                      bottom: 2.0,
                      left: 2.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5), color: AppColors.black.withValues(alpha: 0.7)),
                        child: Text(
                          _duration,
                          style: TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              if (widget.isDuplicate)
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
    );
  }

  Widget _videoDetails(context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(10.0)),
        color: Theme.of(context).cardColor,
      ),
      child: Builder(
        builder: (context) {
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "${_controller.value.size.width.round()}x${_controller.value.size.height.round()} pixels",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ExtendedText(
                  widget.video.path.replaceAll('', '\u200B'),
                  maxLines: 1,
                  overflowWidget: TextOverflowWidget(
                    position: TextOverflowPosition.start,
                    child: Text("..."),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _removeButton(context) {
    return Positioned(
      bottom: 0.0,
      right: 16.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onRemove,
        child: Container(
          padding: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
          ),
          child: Icon(Icons.remove_circle_outline),
        ),
      ),
    );
  }
}
