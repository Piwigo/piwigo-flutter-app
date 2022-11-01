import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/authentication.dart';
import 'package:piwigo_ng/app.dart';
import 'package:piwigo_ng/components/appbars/settings_app_bar.dart';
import 'package:piwigo_ng/components/scroll_widgets/album_grid_view.dart';
import 'package:piwigo_ng/components/scroll_widgets/image_grid_view.dart';
import 'package:piwigo_ng/components/sections/settings_section.dart';
import 'package:piwigo_ng/models/info_model.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:piwigo_ng/views/authentication/login_view_page.dart';
import 'package:piwigo_ng/views/settings/privacy_policy_view_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/theme_provider.dart';

class SettingsViewPage extends StatefulWidget {
  const SettingsViewPage({Key? key}) : super(key: key);

  static const String routeName = '/settings';

  @override
  State<SettingsViewPage> createState() => _SettingsViewPageState();
}

class _SettingsViewPageState extends State<SettingsViewPage> {
  final ScrollController _scrollController = ScrollController();
  late final Future<ApiResult<InfoModel>> _infoFuture;

  late final List<String> _availableSizes;
  late int _imageRowNumber;
  late bool _thumbnailTitle;
  late String _imageThumbnailSize;
  late String _albumThumbnailSize;
  late String _imageFullScreenSize;
  late bool _stripMetadata;
  late String _author;
  late bool _compressBeforeUpload;
  late bool _wifiOnly;
  late bool _deleteAfterUpload;
  late double _quality;

  @override
  void initState() {
    _imageRowNumber = Preferences.getImageRowCount;
    _thumbnailTitle = Preferences.getShowThumbnailTitle;
    _imageThumbnailSize = Preferences.getImageThumbnailSize;
    _imageFullScreenSize = Preferences.getImageFullScreenSize;
    _albumThumbnailSize = Preferences.getAlbumThumbnailSize;
    _availableSizes = Preferences.getAvailableSizes;
    _author = Preferences.getUploadAuthor ?? '';
    _stripMetadata = Preferences.getRemoveMetadata;
    _compressBeforeUpload = Preferences.getCompressUpload;
    _deleteAfterUpload = Preferences.getDeleteAfterUpload;
    _wifiOnly = Preferences.getWifiUpload;
    _quality = Preferences.getUploadQuality;
    super.initState();
    _infoFuture = getInfo();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<double?> _getCacheSize() async {
    int? totalSize = 0;
    final cacheDir = await getTemporaryDirectory();
    try {
      if (cacheDir.existsSync()) {
        cacheDir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalSize = totalSize! + entity.lengthSync();
          }
        });
        return (totalSize! / pow(10, 6));
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future<void> _clearCache() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
    setState(() {});
  }

  String _getServerContent(InfoModel info) {
    String photos = appStrings.imageCount(info.nbImageCategory);
    String albums = appStrings.albumCount(info.nbCategories);
    String tags = appStrings.tagCount(info.nbTags);
    String users = appStrings.userCount(info.nbUsers);
    String groups = appStrings.groupCount(info.nbGroups);
    String comments = appStrings.commentCount(info.nbComments);

    return "$photos | $albums | $tags | $users | $groups | $comments";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SettingsAppBar(
              scrollController: _scrollController,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _serverSection,
                  _logoutSection,
                  if (appPreferences.getString('FILE_TYPES') != null) _supportedFilesSection,
                  _albumsSection,
                  _photosSection,
                  _uploadSection,
                  // _privacySection,
                  _appearanceSection,
                  _cacheSection,
                  _infoSection,
                  _content,
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _serverSection => SettingsSection(
        title: "Piwigo Server ${appPreferences.getString('VERSION')}",
        children: [
          SettingsSectionItemInfo(
            title: appStrings.settings_server,
            child: FutureBuilder<String?>(
              future: FlutterSecureStorage().read(key: 'SERVER_URL'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    "${snapshot.data ?? appStrings.serverURLerror_title}",
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          SettingsSectionItemInfo(
            title: appStrings.settings_username,
            text: appPreferences.getString('ACCOUNT_USERNAME'),
          ),
        ],
      );
  Widget get _logoutSection => SettingsSection(
        children: [
          SettingsSectionButton(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              App.navigatorKey.currentState?.pushNamedAndRemoveUntil(
                LoginViewPage.routeName,
                (route) => false,
              );
            },
            child: Text(
              appStrings.settings_logout,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ],
      );
  Widget get _supportedFilesSection {
    String fileTypes = appPreferences.getString('FILE_TYPES')?.replaceAll(',', ', ') ?? '';
    return SettingsSection(
      color: Colors.transparent,
      children: [
        SettingsSectionItem(
          child: Text(
            appStrings.settingsFooter_formats(fileTypes),
            softWrap: true,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget get _albumsSection => Column(
        children: [
          SettingsSection(
            title: appStrings.tabBar_albums,
            children: [
              SettingsSectionDropdown<String>(
                title: appStrings.defaultThumbnailFile320px,
                value: _albumThumbnailSize,
                onChanged: (size) {
                  if (size != null) {
                    setState(() {
                      _albumThumbnailSize = size;
                      appPreferences.setString(Preferences.albumThumbnailSizeKey, _albumThumbnailSize);
                    });
                  }
                },
                selectedItemBuilder: (context) {
                  return List.generate(_availableSizes.length, (index) {
                    String size = _availableSizes[index];
                    return Center(child: Text("${thumbnailSize(size)}"));
                  });
                },
                items: List.generate(_availableSizes.length, (index) {
                  String size = _availableSizes[index];
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(
                      "${thumbnailSize(size)} ${Settings.getDerivativeRatio(size)}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }),
              ),
            ],
          ),
          ExampleAlbumGridView(
            albumThumbnailSize: _albumThumbnailSize,
          ),
        ],
      );
  Widget get _photosSection => Column(
        children: [
          SettingsSection(
            title: appStrings.settingsHeader_images,
            children: [
              SettingsSectionDropdown<String>(
                title: appStrings.defaultThumbnailFile320px,
                value: _imageThumbnailSize,
                onChanged: (size) {
                  if (size != null) {
                    setState(() {
                      _imageThumbnailSize = size;
                      appPreferences.setString(Preferences.imageThumbnailSizeKey, _imageThumbnailSize);
                    });
                  }
                },
                selectedItemBuilder: (context) {
                  return List.generate(_availableSizes.length, (index) {
                    String size = _availableSizes[index];
                    return Center(child: Text("${thumbnailSize(size)}"));
                  });
                },
                items: List.generate(_availableSizes.length, (index) {
                  String size = _availableSizes[index];
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(
                      "${thumbnailSize(size)} ${Settings.getDerivativeRatio(size)}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }),
              ),
              SettingsSectionDropdown<String>(
                title: appStrings.defaultPreviewFile320px,
                value: _imageFullScreenSize,
                onChanged: (size) {
                  if (size != null) {
                    setState(() {
                      _imageFullScreenSize = size;
                      appPreferences.setString(
                        Preferences.imageFullScreenSizeKey,
                        _imageFullScreenSize,
                      );
                    });
                  }
                },
                selectedItemBuilder: (context) {
                  return List.generate(_availableSizes.length, (index) {
                    String size = _availableSizes[index];
                    return Center(child: Text("${thumbnailSize(size)}"));
                  });
                },
                items: List.generate(_availableSizes.length, (index) {
                  String size = _availableSizes[index];
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(
                      "${photoSize(size)} ${Settings.getDerivativeRatio(size)}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }),
              ),
              Builder(builder: (context) {
                final orientation = MediaQuery.of(context).orientation;
                final int nbImages = Settings.getImageCrossAxisCount(context, _imageRowNumber);
                final int maxNbImages = Settings.getImageCrossAxisCount(context, 6);
                return SettingsSectionItemSlider(
                  enableField: false,
                  title: appStrings.defaultNberOfThumbnailsShort,
                  text: '$nbImages/$maxNbImages',
                  textWidth: orientation == Orientation.portrait ? 24.0 : 40.0,
                  min: Settings.minImageRowCount.toDouble(),
                  max: Settings.maxImageRowCount.toDouble(),
                  divisions: Settings.maxImageRowCount - Settings.minImageRowCount,
                  value: _imageRowNumber.toDouble(),
                  onChanged: (value) => setState(() {
                    _imageRowNumber = value.round();
                    appPreferences.setInt(Preferences.imageRowCountKey, _imageRowNumber);
                  }),
                );
              }),
              SettingsSectionItemSwitch(
                title: appStrings.settings_displayTitles,
                value: _thumbnailTitle,
                onChanged: (value) => setState(() {
                  _thumbnailTitle = value;
                  appPreferences.setBool(Preferences.showThumbnailTitleKey, _thumbnailTitle);
                }),
              ),
            ],
          ),
          ExampleImageGridView(
            nbImageRow: _imageRowNumber,
            imageThumbnailSize: _imageThumbnailSize,
          ),
        ],
      );
  Widget get _uploadSection => SettingsSection(
        title: appStrings.settingsHeader_upload,
        children: [
          SettingsSectionItemField(
            title: appStrings.settings_defaultAuthor320px,
            hint: appStrings.settings_defaultAuthorPlaceholder,
            value: _author,
            onChanged: (value) => setState(() {
              _author = value;
              appPreferences.setString(
                Preferences.uploadAuthorKey,
                _author,
              );
            }),
          ),
          SettingsSectionItemSlider(
            enableField: true,
            title: appStrings.settings_photoQuality,
            text: '${(_quality * 100).toStringAsFixed(0)}%',
            textWidth: 40.0,
            min: 50,
            max: 100,
            divisions: 50,
            value: (_quality * 100).roundToDouble(),
            onChanged: (value) => setState(() {
              _quality = value / 100;
              appPreferences.setDouble(Preferences.uploadQualityKey, _quality);
            }),
          ),
          // const SettingsSectionItemButton(
          //   title: "Privacy",
          //   text: "Everybody",
          // ),
          SettingsSectionItemSwitch(
            title: appStrings.settings_stripGPSdata,
            value: _stripMetadata,
            onChanged: (value) => setState(() {
              _stripMetadata = value;
              appPreferences.setBool(
                Preferences.removeMetadataKey,
                _stripMetadata,
              );
            }),
          ),
          SettingsSectionItemSwitch(
            title: appStrings.settings_photoCompress,
            value: _compressBeforeUpload,
            onChanged: (value) => setState(() {
              _compressBeforeUpload = value;
              appPreferences.setBool(
                Preferences.compressUploadKey,
                _compressBeforeUpload,
              );
            }),
          ),
          SettingsSectionItemSwitch(
            title: appStrings.settings_wifiOnly,
            value: _wifiOnly,
            onChanged: (value) => setState(() {
              _wifiOnly = value;
              appPreferences.setBool(
                Preferences.wifiUploadKey,
                _wifiOnly,
              );
            }),
          ),
          // const SettingsSectionItemButton(
          //   title: "Auto Upload",
          //   text: "Off",
          // ),
          SettingsSectionItemSwitch(
            title: appStrings.settings_deleteImage,
            value: _deleteAfterUpload,
            onChanged: (value) => setState(() {
              _deleteAfterUpload = value;
              appPreferences.setBool(
                Preferences.deleteAfterUploadKey,
                _deleteAfterUpload,
              );
            }),
          ),
        ],
      );
  Widget get _privacySection => SettingsSection(
        title: appStrings.settings_defaultPrivacy,
        children: [
          SettingsSectionItemButton(
            title: "App Lock",
            text: "Off",
          ),
        ],
      ); // todo: use biometry unlock
  Widget get _appearanceSection => SettingsSection(
        title: "Appearance",
        children: [
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, _) {
              return SettingsSectionItemSwitch(
                title: "Dark Theme",
                value: themeNotifier.isDark,
                onChanged: (value) => themeNotifier.toggleTheme(),
              );
            },
          ),
        ],
      );
  Widget get _cacheSection => SettingsSection(
        title: appStrings.settingsHeader_cache,
        children: [
          FutureBuilder<double?>(
            future: _getCacheSize(),
            builder: (context, snapshot) {
              String cacheSize = appStrings.none;
              if (snapshot.hasData && snapshot.data != null) {
                cacheSize = '${snapshot.data!.toStringAsFixed(1)} ${appStrings.settings_cacheMegabytes}';
              }
              return SettingsSectionItemInfo(
                title: appStrings.settings_cacheSize,
                text: cacheSize,
              );
            },
          ),
          SettingsSectionButton(
            onPressed: _clearCache,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 14.0,
              ),
              child: Text(
                appStrings.settings_cacheClear,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
          ),
        ],
      );
  Widget get _infoSection => SettingsSection(
        title: appStrings.settingsHeader_about,
        children: [
          SettingsSectionItemButton(
            title: appStrings.settings_twitter,
            icon: const FaIcon(FontAwesomeIcons.twitter),
            onPressed: () async {
              await launchUrl(
                Uri.parse('https://twitter.com/piwigo'),
              );
            },
          ),
          SettingsSectionItemButton(
            title: appStrings.settings_supportForum,
            icon: const Icon(Icons.message),
            onPressed: () async {
              await launchUrl(
                Uri.parse("https://piwigo.org/forum"),
              );
            },
          ),
          SettingsSectionItemButton(
            title: appStrings.settings_rateInAppStore,
            icon: const Icon(Icons.star_rate),
            onPressed: () async {
              PackageInfo package = await PackageInfo.fromPlatform();
              await launchUrl(
                Uri.parse(
                  "market://details?id=${package.packageName}",
                ),
              );
            },
          ),
          SettingsSectionItemButton(
            title: appStrings.settings_translateWithCrowdin,
            icon: const Icon(Icons.translate),
            onPressed: () async {
              await launchUrl(
                Uri.parse(
                  "https://crowdin.com/project/piwigo-ng",
                ),
              );
            },
          ),
          SettingsSectionItemButton(
            title: appStrings.settings_privacy,
            icon: const Icon(Icons.privacy_tip),
            onPressed: () {
              Navigator.of(context).pushNamed(
                PrivacyPolicyViewPage.routeName,
              );
            },
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                PackageInfo package = snapshot.data!;
                return SettingsSectionItemInfo(
                  title: package.appName,
                  text: package.version,
                );
              }
              return SizedBox();
            },
          ),
        ],
      );
  Widget get _content => SettingsSection(
        color: Colors.transparent,
        children: [
          SettingsSectionItem(
            child: FutureBuilder<ApiResult<InfoModel>>(
              future: _infoFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (!snapshot.data!.hasData) {
                    return const SizedBox();
                  }
                  final InfoModel info = snapshot.data!.data!;
                  return Text(
                    _getServerContent(info),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  );
                }
                return const LinearProgressIndicator();
              },
            ),
          ),
        ],
      );
}
