import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piwigo_ng/api/ImageAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/LoginViewPage.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/views/PrivacyPolicyViewPage.dart';
import 'package:piwigo_ng/views/components/SectionItem.dart';
import 'package:piwigo_ng/views/settings/SettingsLanguagesView.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:piwigo_ng/views/components/appbars.dart';
import 'package:piwigo_ng/views/components/sliders.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = 5;
  String _albumDerivative;
  String _thumbnailDerivative;
  String _fsDerivative;
  double kExpandedHeight = 100.0;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentSliderValue = API.prefs.getInt("recent_albums").toDouble();
    _thumbnailDerivative = API.prefs.getString('thumbnail_size');
  }

  String _parseFilePath(String path) {
    return path.replaceFirst(RegExp(r'/storage/emulated/0'), '');
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            AppBarExpandable(
              scrollController: _scrollController,
              leading: IconButton(
                onPressed: Navigator.of(context).pop,
                icon: Icon(Icons.check, color: _theme.iconTheme.color),
              ),
              title: appStrings(context).tabBar_preferences,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildServerSection(),
                    _buildPhotosSection(),
                    _buildUploadSection(),
                    _buildInfoSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(appStrings(context).settingsHeader_server(API.prefs.getString('version')), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        API.prefs.getString('base_url').substring(0, 4) != 'https' ? Text('') : Padding(
          padding: EdgeInsets.only(left: 10, bottom: 3),
          child: Text(appStrings(context).settingsHeader_notSecure, style: TextStyle(color: Colors.black, fontSize: 12)),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.grey)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SectionItem(
                Text(appStrings(context).settings_server, style: TextStyle(color: Colors.black, fontSize: 16)),
                Text('${API.prefs.getString('base_url')}', overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              ),
              SectionItem(
                Text(appStrings(context).settings_username, style: TextStyle(color: Colors.black, fontSize: 16)),
                Text('${API.prefs.getString('account_username')}', overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                isEnd: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.grey)),
            color: Colors.white,
          ),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
            ),
            onPressed: () {
              API.prefs.setBool("is_logged", false);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) => LoginViewPage(),
                ),
                    (Route route) => false,
              );
            },
            child: Text('${API.prefs.getBool('is_guest') ? appStrings(context).settings_notLoggedIn : appStrings(context).settings_logout }', style: TextStyle(color: Color(0xffff7700), fontSize: 20)),
          ),
        ),
        API.prefs.getString('user_status') == 'admin' || API.prefs.getString('user_status') == 'webmaster' ?
        Center(
          child: Container(
            padding: EdgeInsets.all(5),
            child: Text(
              appStrings(context).settingsFooter_formats(API.prefs.getString("file_types").replaceAll(",", ", ")),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ) :
        Text(''),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, bottom: 3, top: 20),
          child: Text(appStrings(context).settingsHeader_images, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.grey)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SectionItem(
                Text(appStrings(context).settings_displayTitles, style: TextStyle(color: Colors.black, fontSize: 16)),
                Switch(
                  value: API.prefs.getBool('show_thumbnail_title'),
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (bool) {
                    setState(() {
                      API.prefs.setBool('show_thumbnail_title', bool);
                    });
                  },
                ),
              ),
              ImageRowCountSliders(),
              SectionItem(
                Text(appStrings(context).defaultThumbnailSize320px, style: TextStyle(color: Colors.black, fontSize: 16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                      value: _thumbnailDerivative == null ? API.prefs.getString('thumbnail_size') : _thumbnailDerivative,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      underline: Container(),
                      icon: Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
                      onChanged: (String newValue) {
                        setState(() {
                          _thumbnailDerivative = newValue;
                          API.prefs.setString('thumbnail_size', _thumbnailDerivative);
                        });
                      },
                      items: API.prefs.getStringList('available_sizes').map<DropdownMenuItem<String>>((
                          String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(thumbnailSize(context, value)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SectionItem(
                Expanded(
                  child: Text(appStrings(context).defaultImageSize320px,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                DropdownButton<String>(
                  value: _fsDerivative == null ? API.prefs.getString('full_screen_image_size') : _fsDerivative,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  underline: const SizedBox(),
                  icon: Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
                  onChanged: (String newValue) {
                    setState(() {
                      _fsDerivative = newValue;
                      API.prefs.setString('full_screen_image_size', _fsDerivative);
                    });
                  },
                  items: API.prefs.getStringList('available_sizes').map<DropdownMenuItem<String>>((
                      String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(photoSize(context, value)),
                    );
                  }).toList(),
                ),
              ),
              SectionItem(
                Text(appStrings(context).settings_downloadDestination, style: TextStyle(color: Colors.black, fontSize: 16)),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      String path = await pickDirectoryPath();
                      if(path != null) {
                        setState(() {
                          API.prefs.setString('download_destination', path);
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _parseFilePath(API.prefs.getString('download_destination') ?? appStrings(context).none),
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SectionItem(
                Text(appStrings(context).settings_downloadNotification, style: TextStyle(color: Colors.black, fontSize: 16)),
                Switch(
                  value: API.prefs.getBool('download_notification') ?? true,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (bool) {
                    setState(() {
                      API.prefs.setBool('download_notification', bool);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, bottom: 3, top: 20),
          child: Text(appStrings(context).settingsHeader_upload, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.grey)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SectionItem(
                Text(appStrings(context).settings_stripGPSdata, style: TextStyle(color: Colors.black, fontSize: 16)),
                Switch(
                  value: API.prefs.getBool('remove_metadata'),
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (bool) {
                    setState(() {
                      API.prefs.setBool('remove_metadata', bool);
                    });
                  },
                ),
              ),
              SectionItem(
                Text(appStrings(context).settings_uploadNotification, style: TextStyle(color: Colors.black, fontSize: 16)),
                Switch(
                  value: API.prefs.getBool('upload_notification') ?? true,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (bool) {
                    setState(() {
                      API.prefs.setBool('upload_notification', bool);
                    });
                  },
                ),
                isEnd: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, bottom: 3, top: 20),
          child: Text(appStrings(context).settingsHeader_about, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.grey)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SectionItem(
                Text(appStrings(context).settings_twitter, style: TextStyle(color: Colors.black, fontSize: 16)),
                FaIcon(FontAwesomeIcons.twitter, color: Colors.grey.shade600, size: 20),
                onTap: () async {
                  var url = Uri.https("twitter.com", "/piwigo");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              SectionItem(
                Text(appStrings(context).settings_supportForum, style: TextStyle(color: Colors.black, fontSize: 16)),
                FaIcon(FontAwesomeIcons.globe, color: Colors.grey.shade600, size: 20),
                onTap: () async {
                  var url = Uri.https("piwigo.org", "/forum");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              SectionItem(
                Text(appStrings(context).settings_translateWithCrowdin, style: TextStyle(color: Colors.black, fontSize: 16)),
                FaIcon(FontAwesomeIcons.edit, color: Colors.grey.shade600, size: 20),
                onTap: () async {
                  var url = Uri.https("crowdin.com", "/project/piwigo-ng");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              SectionItem(
                Text(appStrings(context).settings_language, style: TextStyle(color: Colors.black, fontSize: 16)),
                FaIcon(FontAwesomeIcons.language, color: Colors.grey.shade600, size: 20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SettingsLanguageView(),
                    ),
                  );
                },
              ),
              SectionItem(
                Text(appStrings(context).settings_privacy, style: TextStyle(color: Colors.black, fontSize: 16)),
                FaIcon(Icons.privacy_tip, color: Colors.grey.shade600, size: 20),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PrivacyPolicyViewPage(),
                    ),
                  );
                },
              ),
              SectionItem(
                Text(appStrings(context).settings_appName, style: TextStyle(color: Colors.black, fontSize: 16)),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData) {
                      return Text(snapshot.data.version,
                        overflow: TextOverflow.ellipsis, softWrap: false,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      );
                    }
                    return SizedBox();
                  },
                ),
                isEnd: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class ImageRowCountSliders extends StatefulWidget {
  const ImageRowCountSliders({Key key}) : super(key: key);

  @override
  _ImageRowCountSlidersState createState() => _ImageRowCountSlidersState();
}
class _ImageRowCountSlidersState extends State<ImageRowCountSliders> {
  @override
  Widget build(BuildContext context) {
    return SectionItemSingle(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Text(appStrings(context).defaultNberOfThumbnails, style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appStrings(context).defaultNberOfThumbnails_portrait,
                  style: TextStyle(color: Colors.black, fontSize: 16)
              ),
              Expanded(
                child: Container(
                  height: 30.0,
                  constraints: BoxConstraints(maxWidth: 300.0),
                  child: PiwigoSlider(
                    label: '${API.prefs.getDouble("portrait_image_count").ceil()}/6',
                    min: Constants.portraitImageCountMin,
                    max: Constants.portraitImageCountMax,
                    value: API.prefs.getDouble("portrait_image_count"),
                    onChangeEnd: (i) {
                      setState(() {
                        API.prefs.setDouble("portrait_image_count", i.ceilToDouble());
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 20,
                child: Text('${API.prefs.getDouble("portrait_image_count").ceil()}',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(appStrings(context).defaultNberOfThumbnails_landscape,
                  style: TextStyle(color: Colors.black, fontSize: 16)
              ),
              Expanded(
                child: Container(
                  height: 30.0,
                  child: PiwigoSlider(
                    label: '${API.prefs.getDouble("landscape_image_count").ceil()}/10',
                    min: Constants.landscapeImageCountMin,
                    max: Constants.landscapeImageCountMax,
                    value: API.prefs.getDouble("landscape_image_count"),
                    onChangeEnd: (i) {
                      setState(() {
                        API.prefs.setDouble("landscape_image_count", i.ceilToDouble());
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 20,
                child: Text('${API.prefs.getDouble("landscape_image_count").ceil()}',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
