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
import 'package:piwigo_ng/components/sections/settings_section.dart';
import 'package:piwigo_ng/models/info_model.dart';
import 'package:piwigo_ng/services/shared_preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/views/authentication/login_view_page.dart';
import 'package:piwigo_ng/views/settings/privacy_policy_view_page.dart';
import 'package:piwigo_ng/views/settings/settings_album_thumbnail_page.dart';
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

  int _recent = 5;
  int _recentPeriod = 7;
  int _numberOfImagesPerRow = 4;
  int _availableCacheDisk = 256;
  int _availableCacheMemory = 32;
  bool _thumbnailTitle = false;
  bool _stripMetadata = false;
  bool _downsizeBeforeUpload = false;
  bool _compressBeforeUpload = false;
  bool _prefixPhotoFilename = false;
  bool _wifiOnly = false;
  bool _deleteAfterUpload = false;
  String _author = "";

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
                  _privacySection,
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

  Widget get _albumsSection => SettingsSection(
        title: appStrings.tabBar_albums,
        children: [
          // SettingsSectionItemButton(
          //   title: appStrings.setDefaultCategory_title,
          //   text: "Root",
          // ),
          SettingsSectionItemButton(
            onPressed: () => Navigator.of(context).pushNamed(
              SettingsAlbumThumbnailPage.routeName,
            ),
            title: "File Size",
            text: "Medium",
          ),
          SettingsSectionItemSlider(
            title: "Recent",
            text: '$_recent/10',
            textWidth: 40,
            hint: "value",
            min: 3,
            max: 10,
            value: _recent.toDouble(),
            onChanged: (value) => setState(() {
              _recent = value.round();
            }),
          ),
          SettingsSectionItemSlider(
            title: "Recent Period",
            text: '$_recentPeriod days',
            textWidth: 49.0,
            hint: "value",
            min: 1,
            max: 99,
            value: _recentPeriod.toDouble(),
            onChanged: (value) => setState(() {
              _recentPeriod = value.round();
            }),
          ),
        ],
      );
  Widget get _photosSection => SettingsSection(
        title: "Photos",
        children: [
          const SettingsSectionItemButton(
            title: "Sort",
            text: "Date Created, old → new",
          ),
          const SettingsSectionItemButton(
            title: "File Size",
            text: "Large",
          ),
          SettingsSectionItemSlider(
            title: "Number",
            text: '$_numberOfImagesPerRow/6',
            textWidth: 24,
            hint: "value",
            min: 3,
            max: 6,
            value: _numberOfImagesPerRow.toDouble(),
            onChanged: (value) => setState(() {
              _numberOfImagesPerRow = value.round();
            }),
          ),
          SettingsSectionItemSwitch(
            title: "Titles on thumbnails",
            value: _thumbnailTitle,
            onChanged: (value) => setState(() {
              _thumbnailTitle = value;
            }),
          ),
          const SettingsSectionItemButton(
            title: "Preview",
            text: "Large",
          ),
          const SettingsSectionItemButton(
            title: "Share Private Metadata",
          ),
        ],
      );
  Widget get _uploadSection => SettingsSection(
        title: "Default Upload Settings",
        children: [
          SettingsSectionItemField(
            title: "Author",
            hint: "Author Name",
            value: _author,
            onChanged: (value) => setState(() {
              _author = value;
            }),
          ),
          const SettingsSectionItemButton(
            title: "Privacy",
            text: "Everybody",
          ),
          SettingsSectionItemSwitch(
            title: "Strip Private Metadata",
            value: _stripMetadata,
            onChanged: (value) => setState(() {
              _stripMetadata = value;
            }),
          ),
          SettingsSectionItemSwitch(
            title: "Downsize Before Upload",
            value: _downsizeBeforeUpload,
            onChanged: (value) => setState(() {
              _downsizeBeforeUpload = value;
            }),
          ),
          SettingsSectionItemSwitch(
            title: "Compress Before Upload",
            value: _compressBeforeUpload,
            onChanged: (value) => setState(() {
              _compressBeforeUpload = value;
            }),
          ),
          SettingsSectionItemSwitch(
            title: "Prefix Photo Filename",
            value: _prefixPhotoFilename,
            onChanged: (value) => setState(() {
              _prefixPhotoFilename = value;
            }),
          ),
          SettingsSectionItemSwitch(
            title: "Wi-Fi Only",
            value: _wifiOnly,
            onChanged: (value) => setState(() {
              _wifiOnly = value;
            }),
          ),
          const SettingsSectionItemButton(
            title: "Auto Upload",
            text: "Off",
          ),
          SettingsSectionItemSwitch(
            title: "Delete After Upload",
            value: _deleteAfterUpload,
            onChanged: (value) => setState(() {
              _deleteAfterUpload = value;
            }),
          ),
        ],
      );
  Widget get _privacySection => const SettingsSection(
        title: "Privacy",
        children: [
          SettingsSectionItemButton(
            title: "App Lock",
            text: "Off",
          ),
          SettingsSectionItemButton(
            title: "Clear Clipboard",
            text: "Never",
          ),
        ],
      );
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
        title: "Cache Settings (Used/Total)",
        children: [
          SettingsSectionItemSlider(
            title: "Disk",
            text: '1/$_availableCacheDisk',
            textWidth: 49,
            min: 128,
            max: 2048,
            divisions: 30,
            value: _availableCacheDisk.toDouble(),
            onChanged: (value) => setState(() {
              _availableCacheDisk = value.round();
            }),
          ),
          SettingsSectionItemSlider(
            title: "Memory",
            text: '1/$_availableCacheMemory',
            textWidth: 40,
            min: 0,
            max: 256,
            divisions: 32,
            value: _availableCacheMemory.toDouble(),
            onChanged: (value) => setState(() {
              _availableCacheMemory = value.round();
            }),
          ),
          FutureBuilder<double?>(
            future: _getCacheSize(),
            builder: (context, snapshot) {
              String cacheSize = 'N/A';
              if (snapshot.hasData && snapshot.data != null) {
                cacheSize = '${snapshot.data!.toStringAsFixed(1)} MB';
              }
              return SettingsSectionItemInfo(
                title: 'Cache size',
                text: cacheSize,
              );
            },
          ),
          SettingsSectionButton(
            onPressed: _clearCache,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 14,
              ),
              child: Text(
                "Clear Cache",
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
        title: "Information",
        children: [
          SettingsSectionItemButton(
            title: "@piwigo",
            icon: const FaIcon(FontAwesomeIcons.twitter),
            onPressed: () async {
              await launchUrl(
                Uri.parse("https://twitter.com/piwigo"),
              );
            },
          ),
          const SettingsSectionItemButton(
            title: "Contact us",
            disabled: true,
          ),
          SettingsSectionItemButton(
            title: "Support Forum",
            icon: const Icon(Icons.message),
            onPressed: () async {
              await launchUrl(
                Uri.parse("https://piwigo.org/forum"),
              );
            },
          ),
          SettingsSectionItemButton(
            title: "Rate on Play Store",
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
            title: "Translate Piwigo NG",
            icon: const Icon(Icons.translate),
            onPressed: () async {
              PackageInfo package = await PackageInfo.fromPlatform();
              await launchUrl(
                Uri.parse(
                  "https://crowdin.com/project/piwigo-ng",
                ),
              );
            },
          ),
          // const SettingsSectionItemButton(
          //   title: "Release Notes",
          // ),
          // const SettingsSectionItemButton(
          //   title: "Acknowledgements",
          // ),
          SettingsSectionItemButton(
            title: "Privacy Policy",
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
              future: getInfo(),
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
