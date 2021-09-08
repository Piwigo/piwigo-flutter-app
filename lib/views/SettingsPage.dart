
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/views/LoginViewPage.dart';
import 'package:piwigo_ng/api/API.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = 5;
  String _albumDerivative;
  String _thumbnailDerivative;
  String _fsDerivative;

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
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 100.0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.check, color: _theme.iconTheme.color),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                // Consumer<ThemeNotifier>(
                //   builder: (context, notifier, child) => Switch(
                //     onChanged:(value){
                //       notifier.toggleTheme();
                //     },
                //     value: notifier.darkTheme,
                //   ),
                // ),
                // TODO: Add tutorials
                //Icon(Icons.info_outline, color: _theme.iconTheme.color),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(appStrings(context).tabBar_preferences, style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w900, color: Color(0xff000000))),
                  ),
                ],
              ),
            ),
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
                              tableCell(
                                Text(appStrings(context).settings_server, style: TextStyle(color: Colors.black, fontSize: 16)),
                                Text('${API.prefs.getString('base_url')}', overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                              ),
                              tableCell(
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
                              tableCell(
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
                              tableCell(
                                Text(appStrings(context).settings_portraitNberOfThumbnails, style: TextStyle(color: Colors.black, fontSize: 16)),
                                Expanded(
                                  child: Slider(
                                    label: '${API.prefs.getDouble("portrait_image_count").ceil()}/6',
                                    activeColor: Color(0xffff7700),
                                    inactiveColor: Color(0xffeeeeee),
                                    divisions: 5,
                                    min: Constants.PORTRAIT_IMAGE_COUNT_MIN,
                                    max: Constants.PORTRAIT_IMAGE_COUNT_MAX,
                                    value: API.prefs.getDouble("portrait_image_count"),
                                    onChanged: (i) {
                                      setState(() {
                                        print(i.ceilToDouble());
                                        API.prefs.setDouble("portrait_image_count", i.ceilToDouble());
                                      });
                                    },
                                  ),
                                ),
                              ),
                              tableCell(
                                Text(appStrings(context).settings_landscapeNberOfThumbnails, style: TextStyle(color: Colors.black, fontSize: 16)),
                                Expanded(
                                  child: Slider(
                                    label: '${API.prefs.getDouble("landscape_image_count").ceil()}/10',
                                    activeColor: Color(0xffff7700),
                                    inactiveColor: Color(0xffeeeeee),
                                    divisions: 6,
                                    min: Constants.LANDSCAPE_IMAGE_COUNT_MIN,
                                    max: Constants.LANDSCAPE_IMAGE_COUNT_MAX,
                                    value: API.prefs.getDouble("landscape_image_count"),
                                    onChanged: (i) {
                                      setState(() {
                                        print(i.ceilToDouble());
                                        API.prefs.setDouble("landscape_image_count", i.ceilToDouble());
                                      });
                                    },
                                  ),
                                ),
                              ),
                              tableCell(
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
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              tableCell(
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
                                          child: Text(value),
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
                              tableCell(
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

  Widget tableCell(Widget left, Widget right, {List<Widget> options, bool isEnd = false}) {
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
