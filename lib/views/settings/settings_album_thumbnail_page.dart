import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/scroll_widgets/album_grid_view.dart';
import 'package:piwigo_ng/components/sections/settings_section.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';

class SettingsAlbumThumbnailPage extends StatefulWidget {
  const SettingsAlbumThumbnailPage({Key? key}) : super(key: key);

  static const String routeName = '/settings/album_thumbnail';

  @override
  State<SettingsAlbumThumbnailPage> createState() => _SettingsAlbumThumbnailPageState();
}

class _SettingsAlbumThumbnailPageState extends State<SettingsAlbumThumbnailPage> {
  List<String> _availableSizes = [];
  late String _size;

  @override
  void initState() {
    _availableSizes.addAll(appPreferences.getStringList('AVAILABLE_SIZES') ?? []);
    _size = appPreferences.getString('ALBUM_THUMBNAIL_SIZE') ?? _availableSizes.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(appStrings.defaultAlbumThumbnailFile414px),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(appStrings.defaultAlbumThumbnailSizeHeader),
                  ),
                  SettingsSection(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButton<String>(
                          value: _size,
                          isExpanded: true,
                          underline: const SizedBox(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          onChanged: (size) {
                            if (size != null) {
                              setState(() {
                                _size = size;
                              });
                            }
                          },
                          items: List.generate(_availableSizes.length, (index) {
                            String size = _availableSizes[index];
                            return DropdownMenuItem<String>(
                              value: size,
                              child: Text("$size (${Settings.getDerivativeRatio(size)})"),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  AlbumGridView(
                    albumList: [
                      AlbumModel(
                        id: 0,
                        name: 'weird_cat',
                        urlRepresentative: 'assets/example/weird_cat/$_size.jpg',
                      ),
                      AlbumModel(
                        id: 0,
                        name: 'weird_cat',
                        urlRepresentative: 'assets/example/weird_cat/$_size.jpg',
                      ),
                      AlbumModel(
                        id: 0,
                        name: 'weird_cat',
                        urlRepresentative: 'assets/example/weird_cat/$_size.jpg',
                      ),
                      AlbumModel(
                        id: 0,
                        name: 'weird_cat',
                        urlRepresentative: 'assets/example/weird_cat/$_size.jpg',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
