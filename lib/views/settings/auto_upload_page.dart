import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/components/modals/move_or_copy_modal.dart';
import 'package:piwigo_ng/components/sections/settings_section.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/services/auto_upload_manager.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class AutoUploadPage extends StatefulWidget {
  const AutoUploadPage({Key? key}) : super(key: key);

  static const String routeName = '/settings/auto_upload';

  @override
  State<AutoUploadPage> createState() => _AutoUploadPageState();
}

class _AutoUploadPageState extends State<AutoUploadPage> {
  final List<Duration> _periods = [
    Duration(hours: 1),
    Duration(hours: 6),
    Duration(hours: 12),
    Duration(days: 1),
    Duration(days: 7),
  ];
  AutoUploadManager _manager = AutoUploadManager();
  late bool _autoUploadEnabled;
  late Duration _selectedPeriod;
  AlbumModel? _album;

  @override
  void initState() {
    _autoUploadEnabled = Preferences.getAutoUpload;
    _selectedPeriod = _periods.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appStrings.settings_autoUpload),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          SettingsSection(
            children: [
              SettingsSectionItemSwitch(
                title: appStrings.settings_autoUpload,
                value: _autoUploadEnabled,
                onChanged: (value) => setState(() {
                  _autoUploadEnabled = value;
                  if (value) {
                    if (Preferences.getAutoUploadDestination == null || Preferences.getAutoUploadSource == null) {
                      _autoUploadEnabled = false;
                      return;
                    }
                    _manager.startAutoUpload();
                  } else {
                    _manager.endAutoUpload();
                  }
                }),
              ),
            ],
          ),
          SettingsSection(
            children: [
              SettingsSectionItemButton(
                title: appStrings.settings_autoUploadSource,
                text: Preferences.getAutoUploadSource ?? appStrings.none,
                onPressed: () async {
                  String? dir = await pickDirectoryPath();
                  if (dir == null) return;
                  setState(() async {
                    await appPreferences.setString(
                      Preferences.autoUploadSourceKey,
                      dir,
                    );
                  });
                },
              ),
              SettingsSectionItemButton(
                title: appStrings.settings_autoUploadDestination,
                text: _album?.name ?? appStrings.none,
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => Padding(
                      padding: MediaQuery.of(context).padding,
                      child: MoveOrCopyModal(
                        title: appStrings.settings_autoUploadDestination,
                        subtitle: appStrings.settings_autoUploadDestinationInfo,
                        isImage: true,
                        onSelected: (selectedAlbum) async {
                          setState(() {
                            _album = selectedAlbum;
                          });
                          return true;
                        },
                      ),
                    ),
                  );
                },
              ),
              SettingsSectionDropdown<Duration>(
                title: appStrings.settings_autoUploadPeriod,
                value: _selectedPeriod,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedPeriod = value;
                  });
                  _manager.endAutoUpload();
                  _manager.startAutoUpload();
                },
                items: List.generate(
                  _periods.length,
                  (index) => DropdownMenuItem<Duration>(
                    value: _periods[index],
                    child: Text(
                      _getPeriodText(_periods[index]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPeriodText(Duration period) {
    if (period.inHours == 0) {
      return appStrings.settings_autoUploadPeriodMinutes(period.inMinutes);
    } else if (period.inDays == 0) {
      return appStrings.settings_autoUploadPeriodHours(period.inHours);
    }
    return appStrings.settings_autoUploadPeriodDays(period.inDays);
  }
}
