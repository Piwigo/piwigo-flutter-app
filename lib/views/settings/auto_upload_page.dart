import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/modals/move_or_copy_modal.dart';
import 'package:piwigo_ng/components/modals/piwigo_modal.dart';
import 'package:piwigo_ng/components/sections/settings_section.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/network/images.dart';
import 'package:piwigo_ng/services/auto_upload_manager.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';

class AutoUploadPage extends StatefulWidget {
  const AutoUploadPage({Key? key}) : super(key: key);

  static const String routeName = '/settings/auto_upload';

  @override
  State<AutoUploadPage> createState() => _AutoUploadPageState();
}

class _AutoUploadPageState extends State<AutoUploadPage> {
  AutoUploadManager _manager = AutoUploadManager();
  late bool _autoUploadEnabled;
  late Duration _selectedFrequency;
  late bool _autoUploadNotification;
  AlbumModel? _album;
  String? _sourcePath;

  @override
  void initState() {
    _sourcePath = AutoUploadPreferences.getSource;
    _album = AutoUploadPreferences.getDestination;
    _autoUploadEnabled = AutoUploadPreferences.getEnabled;
    _selectedFrequency = AutoUploadPreferences.getFrequency;
    _autoUploadNotification = AutoUploadPreferences.getNotification;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appStrings.settings_autoUpload),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          SettingsSection(
            children: [
              SettingsSectionItemSwitch(
                title: appStrings.settings_autoUpload,
                value: _autoUploadEnabled,
                onChanged: (value) {
                  if (AutoUploadPreferences.getDestination == null ||
                      AutoUploadPreferences.getSource == null) {
                    return;
                  }
                  setState(() {
                    _autoUploadEnabled = value;
                    if (value) {
                      _manager.startAutoUpload();
                    } else {
                      _manager.endAutoUpload();
                    }
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              appStrings.settings_autoUploadDuplicateInfo,
              textAlign: TextAlign.center,
            ),
          ),
          SettingsSection(
            children: [
              SettingsSectionItemButton(
                title: appStrings.settings_autoUploadSource,
                text: _sourcePath ?? appStrings.none,
                onPressed: () async {
                  String? dir = await pickDirectoryPath();
                  if (dir == null || dir == _sourcePath) return;
                  bool success = await AutoUploadPreferences.setSource(dir);
                  if (!success) return;
                  setState(() {
                    _sourcePath = dir;
                  });
                  _manager.endAutoUpload();
                },
              ),
              SettingsSectionItemButton(
                title: appStrings.settings_autoUploadDestination,
                text: _album?.name ?? appStrings.none,
                onPressed: () async {
                  await showPiwigoModal(
                    context: context,
                    builder: (_) => MoveOrCopyModal(
                      title: appStrings.settings_autoUploadDestination,
                      subtitle: appStrings.settings_autoUploadDestinationInfo,
                      isImage: true,
                      onSelected: (selectedAlbum) async {
                        if (_album == selectedAlbum) return true;
                        bool success =
                            await AutoUploadPreferences.setDestination(
                                selectedAlbum);
                        if (!success) return false;
                        setState(() {
                          _album = selectedAlbum;
                        });
                        _manager.endAutoUpload();
                        return true;
                      },
                    ),
                  );
                },
              ),
              SettingsSectionDropdown<Duration>(
                title: appStrings.settings_autoUploadFrequency,
                value: _selectedFrequency,
                onChanged: (value) async {
                  if (value == null || _selectedFrequency == value) return;
                  bool success =
                      await AutoUploadPreferences.setFrequency(value);
                  if (!success) return;
                  setState(() {
                    _autoUploadEnabled = false;
                    _selectedFrequency = value;
                  });
                  _manager.endAutoUpload();
                },
                items: List.generate(Settings.autoUploadFrequencies.length,
                    (index) {
                  Duration frequency = Settings.autoUploadFrequencies[index];
                  return DropdownMenuItem<Duration>(
                    value: frequency,
                    child: Text(
                      _getFrequencyText(frequency),
                    ),
                  );
                }),
              ),
              SettingsSectionItemSwitch(
                title: appStrings.settings_uploadNotification,
                value: _autoUploadNotification,
                onChanged: (value) => setState(() {
                  _autoUploadNotification = value;
                  AutoUploadPreferences.setNotification(
                    _autoUploadNotification,
                  );
                }),
              ),
            ],
          ),
          if (AutoUploadPreferences.getDestination == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.warning),
                  SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      appStrings.settings_autoUploadDestinationInfo,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          if (AutoUploadPreferences.getSource == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.warning),
                  SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      appStrings.settings_autoUploadSourceInfo,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getFrequencyText(Duration frequency) {
    if (frequency.inHours == 0) {
      return appStrings
          .settings_autoUploadFrequencyMinutes(frequency.inMinutes);
    } else if (frequency.inDays == 0) {
      return appStrings.settings_autoUploadFrequencyHours(frequency.inHours);
    }
    return appStrings.settings_autoUploadFrequencyDays(frequency.inDays);
  }
}
