
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/LoginViewPage.dart';
import 'package:piwigo_ng/api/API.dart';
import 'package:piwigo_ng/views/PrivacyPolicyViewPage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/AppBars.dart';
import 'components/sliders.dart';


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

  @override
  void initState() {
    super.initState();
    _currentSliderValue = API.prefs.getInt("recent_albums").toDouble();
    _thumbnailDerivative = API.prefs.getString('thumbnail_size');
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          AppBarExpandable(
            leading: IconButton(
              onPressed: Navigator.of(context).pop,
              icon: Icon(Icons.check, color: _theme.iconTheme.color),
            ),
            title: appStrings(context).tabBar_preferences,
          ),
          SliverPadding(
            padding: EdgeInsets.only(top: 30),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                  return Container(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
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
                              TableCell(
                                Text(appStrings(context).settings_server, style: TextStyle(color: Colors.black, fontSize: 16)),
                                Text('${API.prefs.getString('base_url')}', overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                              ),
                              TableCell(
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
                              child: Text(appStrings(context).settingsFooter_formats(API.prefs.getString("file_types").replaceAll(",", ", ")),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontSize: 12)),
                            ),
                          ) :
                          Text(''),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 3),
                          child: Text(appStrings(context).settingsHeader_images, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.grey)),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              TableCell(
                                Text(appStrings(context).settings_displayTitles, style: TextStyle(color: Colors.black, fontSize: 16)),
                                Switch(
                                  value: API.prefs.getBool('show_thumbnail_title'),
                                  onChanged: (bool) {
                                    setState(() {
                                      API.prefs.setBool('show_thumbnail_title', bool);
                                    });
                                  },
                                ),
                              ),
                              ImageRowCountSliders(),
                              TableCell(
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
                              TableCell(
                                Text(appStrings(context).defaultImageSize320px, style: TextStyle(color: Colors.black, fontSize: 16)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    DropdownButton<String>(
                                      value: _fsDerivative == null ? API.prefs.getString('full_screen_image_size') : _fsDerivative,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                      underline: Container(),
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
                                          child: Text(photoSize(context, value)),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                isEnd: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 3),
                          child: Text(appStrings(context).settingsHeader_about, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.grey)),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var url = appStrings(context).settings_twitterURL;
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: TableCell(
                                  Text(appStrings(context).settings_twitter, style: TextStyle(color: Colors.black, fontSize: 16)),
                                  FaIcon(FontAwesomeIcons.twitter, color: Colors.grey.shade600, size: 20),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  var url = appStrings(context).settings_pwgForumURL;
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: TableCell(
                                  Text(appStrings(context).settings_supportForum, style: TextStyle(color: Colors.black, fontSize: 16)),
                                  FaIcon(FontAwesomeIcons.globe, color: Colors.grey.shade600, size: 20),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  var url = appStrings(context).settings_crowdinURL;
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: TableCell(
                                  Text(appStrings(context).settings_translateWithCrowdin, style: TextStyle(color: Colors.black, fontSize: 16)),
                                  FaIcon(FontAwesomeIcons.language, color: Colors.grey.shade600, size: 20),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => PrivacyPolicyViewPage())
                                  );
                                },
                                child: TableCell(
                                  Text(appStrings(context).settings_privacy, style: TextStyle(color: Colors.black, fontSize: 16)),
                                  FaIcon(Icons.privacy_tip, color: Colors.grey.shade600, size: 20),
                                ),
                              ),
                              TableCell(
                                Text(appStrings(context).settings_appName, style: TextStyle(color: Colors.black, fontSize: 16)),
                                Text(dotenv.env['APP_VERSION'], overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                isEnd: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class TableCell extends StatelessWidget {
  const TableCell(this.left, this.right, {Key key, this.options, this.isEnd = false}) : super(key: key);

  final Widget left;
  final Widget right;
  final List<Widget> options;
  final bool isEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(left: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: isEnd ? Border.all(width: 0, color: Colors.white) : Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
        color: Colors.white,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            left,
            right,
          ] + (options ?? []),
        ),
      ),
    );
  }
}

class TableCellSingle extends StatelessWidget {
  const TableCellSingle(this.content, {Key key, this.isEnd = false}) : super(key: key);

  final Widget content;
  final bool isEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 5),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: isEnd ? Border.all(width: 0, color: Colors.white) : Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
        color: Colors.white,
      ),
      child: Center(
        child: content,
      ),
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
    return TableCellSingle(
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
              Row(
                children: [
                  Container(
                    height: 30.0,
                    width: 300.0,
                    child: PiwigoSlider(
                      label: '${API.prefs.getDouble("portrait_image_count").ceil()}/6',
                      min: Constants.PORTRAIT_IMAGE_COUNT_MIN,
                      max: Constants.PORTRAIT_IMAGE_COUNT_MAX,
                      value: API.prefs.getDouble("portrait_image_count"),
                      onChangeEnd: (i) {
                        setState(() {
                          API.prefs.setDouble("portrait_image_count", i.ceilToDouble());
                        });
                      },
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
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appStrings(context).defaultNberOfThumbnails_landscape,
                  style: TextStyle(color: Colors.black, fontSize: 16)
              ),
              Row(
                children: [
                  Container(
                    height: 30.0,
                    width: 300.0,
                    child: PiwigoSlider(
                      label: '${API.prefs.getDouble("landscape_image_count").ceil()}/10',
                      min: Constants.LANDSCAPE_IMAGE_COUNT_MIN,
                      max: Constants.LANDSCAPE_IMAGE_COUNT_MAX,
                      value: API.prefs.getDouble("landscape_image_count"),
                      onChangeEnd: (i) {
                        setState(() {
                          API.prefs.setDouble("landscape_image_count", i.ceilToDouble());
                        });
                      },
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
        ],
      ),
    );
  }
}

