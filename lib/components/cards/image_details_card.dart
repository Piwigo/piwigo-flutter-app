import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/locale_provider.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:provider/provider.dart';

class ImageDetailsCard extends StatelessWidget {
  const ImageDetailsCard({Key? key, required this.image, this.onRemove})
      : super(key: key);

  final ImageModel image;
  final Function()? onRemove;

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
              final String? imageUrl = image
                  .getDerivativeFromString(Preferences.getImageThumbnailSize)
                  ?.url;
              return Image.network(
                imageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, o, s) {
                  debugPrint("$o\n$s");
                  return Center(child: Icon(Icons.image_not_supported));
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
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
                    image.file
                        .replaceAll('', '\u200B')
                        .split(path.extension(image.file))
                        .first,
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
              LocaleNotifier localeNotifier =
                  Provider.of<LocaleNotifier>(context, listen: false);
              String date =
                  DateFormat.yMMMMd(localeNotifier.locale.languageCode)
                      .format(DateTime.parse(image.dateAvailable!));
              String time = DateFormat.Hms(localeNotifier.locale.languageCode)
                  .format(DateTime.parse(image.dateAvailable!));
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
