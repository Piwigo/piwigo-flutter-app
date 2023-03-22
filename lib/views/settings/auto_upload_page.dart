import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/components/buttons/piwigo_button.dart';
import 'package:piwigo_ng/components/modals/move_or_copy_modal.dart';
import 'package:piwigo_ng/components/sections/settings_section.dart';
import 'package:piwigo_ng/models/album_model.dart';
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
  AlbumModel? _album;
  String? _sourcePath;

  @override
  void initState() {
    _sourcePath = AutoUploadPrefs.getAutoUploadSource;
    _album = AutoUploadPrefs.getAutoUploadDestination;
    _autoUploadEnabled = AutoUploadPrefs.getAutoUpload;
    _selectedFrequency = AutoUploadPrefs.getAutoUploadFrequency;
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
                onChanged: (value) => setState(() {
                  _autoUploadEnabled = value;
                  if (value) {
                    if (AutoUploadPrefs.getAutoUploadDestination == null || AutoUploadPrefs.getAutoUploadSource == null) {
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
                text: _sourcePath ?? appStrings.none,
                onPressed: () async {
                  String? dir = await pickDirectoryPath();
                  if (dir == null || dir == _sourcePath) return;
                  bool success = await AutoUploadPrefs.setAutoUploadSource(dir);
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
                          if (_album == selectedAlbum) return true;
                          bool success = await AutoUploadPrefs.setAutoUploadDestination(selectedAlbum);
                          if (!success) return false;
                          setState(() {
                            _album = selectedAlbum;
                          });
                          _manager.endAutoUpload();
                          return true;
                        },
                      ),
                    ),
                  );
                },
              ),
              SettingsSectionDropdown<Duration>(
                title: appStrings.settings_autoUploadFrequency,
                value: _selectedFrequency,
                onChanged: (value) async {
                  if (value == null || _selectedFrequency == value) return;
                  bool success = await AutoUploadPrefs.setAutoUploadFrequency(value);
                  if (!success) return;
                  setState(() {
                    _selectedFrequency = value;
                  });
                  _manager.endAutoUpload();
                },
                items: List.generate(Settings.autoUploadFrequencies.length, (index) {
                  Duration frequency = Settings.autoUploadFrequencies[index];
                  return DropdownMenuItem<Duration>(
                    value: frequency,
                    child: Text(
                      _getFrequencyText(frequency),
                    ),
                  );
                }),
              ),
            ],
          ),
          // todo: remove
          PiwigoButton(
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            color: Theme.of(context).colorScheme.secondary,
            text: 'Debug auto upload',
            onPressed: () => AutoUploadManager().autoUpload(),
          ),
        ],
      ),
    );
  }

  String _getFrequencyText(Duration frequency) {
    if (frequency.inHours == 0) {
      return appStrings.settings_autoUploadFrequencyMinutes(frequency.inMinutes);
    } else if (frequency.inDays == 0) {
      return appStrings.settings_autoUploadFrequencyHours(frequency.inHours);
    }
    return appStrings.settings_autoUploadFrequencyDays(frequency.inDays);
  }
}
