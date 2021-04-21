
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poc_piwigo/constants/SettingsConstants.dart';
import 'package:poc_piwigo/views/LoginViewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RootCategoryViewPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = 5;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);
    return Scaffold(
      body:FutureBuilder(
        future: SharedPreferences.getInstance(), // Albums of the list
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            SharedPreferences prefs = snapshot.data;
            _currentSliderValue = prefs.getInt("recent_albums").toDouble();
            return CustomScrollView(
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
                      Icon(Icons.info_outline, color: _theme.iconTheme.color),
                    ],
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Text("Settings", style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w900, color: Color(0xff000000))),
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
                                child: Text('Piwigo Server ${prefs.getString('version')}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10, bottom: 3),
                                child: Text(prefs.getString('base_url').substring(0, 4) != 'https' ? 'Unsecured Website !' : 'Secured Website', style: TextStyle(color: Colors.black, fontSize: 12)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.grey)),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    tableCell(
                                      Text('Address', style: TextStyle(color: Colors.black, fontSize: 16)),
                                      Text('${prefs.getString('base_url')}', overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                    ),
                                    tableCellEnd(
                                      Text('Username', style: TextStyle(color: Colors.black, fontSize: 16)),
                                      Text('${prefs.getString('account_username')}', overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
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
                                    if(prefs.getBool('is_guest')) {
                                      print('Log in');
                                    } else {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        // the new route
                                        MaterialPageRoute(
                                          builder: (BuildContext context) => LoginViewPage(),
                                        ),

                                        // this function should return true when we're done removing routes
                                        // but because we want to remove all other screens, we make it
                                        // always return false
                                            (Route route) => false,
                                      );
                                    }
                                  },
                                  child: Text('${prefs.getBool('is_guest') ? 'Log in' : 'Log out' }', style: TextStyle(color: Color(0xffff7700), fontSize: 20),),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text('This server handles these file types: ${prefs.getString("file_types")}', style: TextStyle(color: Colors.black, fontSize: 12)),
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.only(left: 10, bottom: 3),
                                child: Text('Albums', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.symmetric(horizontal: BorderSide(width: 0.5, color: Colors.grey)),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        print('change root album');
                                      },
                                      child: tableCell(
                                        Text('Default Album', style: TextStyle(color: Colors.black, fontSize: 16)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text('${prefs.getString('default_album')}', overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                            SizedBox(width: 10),
                                            Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        print('change image miniatures size');
                                      },
                                      child: tableCell(
                                        Text('Miniatures', style: TextStyle(color: Colors.black, fontSize: 16)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text('${prefs.getStringList('available_sizes')[prefs.getInt("default_miniatures_size")]}', overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                            SizedBox(width: 10),
                                            Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        print('change sort');
                                      },
                                      child: tableCell(
                                        Text('Sort', style: TextStyle(color: Colors.black, fontSize: 16)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text('${albumSort[prefs.getInt('sort')]}', overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                            SizedBox(width: 10),
                                            Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    tableCellEnd(
                                      Text('Recent Albums', style: TextStyle(color: Colors.black, fontSize: 16)),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Slider(
                                                  activeColor: Color(0xffff7700),
                                                  inactiveColor: Color(0xffeeeeee),
                                                  min: 3,
                                                  max: 10,
                                                  divisions: 7,
                                                  value: _currentSliderValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _currentSliderValue = value;
                                                    });
                                                    prefs.setInt('recent_albums', value.ceil());
                                                  }
                                              ),
                                            ),
                                            SizedBox(
                                              width: 40,
                                              child: Text("${_currentSliderValue.toInt()}/10", style: TextStyle(color: Colors.grey.shade600, fontSize: 14), textAlign: TextAlign.end,),
                                            ),
                                          ],
                                        ),
                                      ),
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
            );
          } else {
            return CircularProgressIndicator();
          }
        }
      )
    );
  }

  Widget tableCell(Widget left, Widget right) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(left: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
        color: Colors.white,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            left,
            right,
          ],
        ),
      ),
    );
  }
  Widget tableCellEnd(Widget left, Widget right) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(left: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            left,
            right,
          ],
        ),
      ),
    );
  }
}
