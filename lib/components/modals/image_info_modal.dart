import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:piwigo_ng/components/cards/piwigo_chip.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:piwigo_ng/components/sections/settings_section.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/services/locale_provider.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:provider/provider.dart';

class ImageInfoModal extends StatelessWidget {
  const ImageInfoModal({Key? key, required this.image}) : super(key: key);

  final ImageModel image;

  String _getDate(BuildContext context, String date) {
    LocaleNotifier localeNotifier =
        Provider.of<LocaleNotifier>(context, listen: false);

    return DateFormat.yMMMMd(localeNotifier.locale.languageCode)
        .format(DateTime.parse(image.dateAvailable!));
  }

  String _getTime(BuildContext context, String date) {
    LocaleNotifier localeNotifier =
        Provider.of<LocaleNotifier>(context, listen: false);

    return DateFormat.Hms(localeNotifier.locale.languageCode)
        .format(DateTime.parse(image.dateAvailable!));
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoModal(
      title: appStrings.imageDetailsView_title,
      content: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                image.name ?? "",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (image.comment != null) Text(image.comment!),
            const SizedBox(height: 8.0),
            SettingsSection(
              margin: EdgeInsets.zero,
              title: appStrings.settingsHeader_about,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(image.file),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${image.width}x${image.height} px"),
                ),
                if (image.dateCreation != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(appStrings.imageDetails_dateCreated(
                      _getDate(context, image.dateCreation!),
                      _getTime(context, image.dateCreation!),
                    )),
                  ),
                ],
                if (image.dateAvailable != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(appStrings.imageDetails_dateAvailable(
                      _getDate(context, image.dateAvailable!),
                      _getTime(context, image.dateAvailable!),
                    )),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(appStrings
                      .imageDetails_nbAlbums(image.categories.length)),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            FormSection(
              title: appStrings.tags,
              titlePadding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 8.0,
                children: List.generate(
                  image.tags.length,
                  (index) => PiwigoChip(
                    label: image.tags[index].name,
                    backgroundColor:
                        Theme.of(context).chipTheme.backgroundColor,
                    foregroundColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showImageDetailsModal(
  BuildContext context,
  ImageModel image,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (_) => ImageInfoModal(image: image),
  );
}
