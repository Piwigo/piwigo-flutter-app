import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/model/CategoryModel.dart';
import 'package:piwigo_ng/services/MoveAlbumService.dart';

import 'piwigo_dialog.dart';



class MoveOrCopyDialog extends StatefulWidget {
  const MoveOrCopyDialog({
    Key key,
    this.isImage = false,
    this.catId = "0",
    this.onSelected,
    this.catName = "",
    this.title = "",
    this.subtitle = ""
  }) : super(key: key);

  final bool isImage;
  final String catId;
  final String catName;
  final String title;
  final String subtitle;
  final Function(CategoryModel) onSelected;

  @override
  _MoveOrCopyDialogState createState() => _MoveOrCopyDialogState();
}
class _MoveOrCopyDialogState extends State<MoveOrCopyDialog> {

  CategoryModel _createAlbumTree(snapshot) {
    CategoryModel root = CategoryModel("0", appStrings(context).categorySelection_root, fullname: appStrings(context).categorySelection_root);
    snapshot.data['result']['categories'].forEach((cat) {
      List<int> rank = cat['global_rank'].split('.').map(int.parse).toList().cast<int>();
      CategoryModel newCat = CategoryModel.fromJson(cat);
      if(rank.length > 1) {
        CategoryModel nextInputCat = root.children.elementAt(rank.first-1);
        rank.removeAt(0);
        addCatRecursive(rank, newCat, nextInputCat);
      } else {
        root.children.add(newCat);
      }
    });
    return root;
  }

  @override
  Widget build(BuildContext context) {
    return PiwigoDialog(
      height: MediaQuery.of(context).size.height*0.8,
      title: widget.title,
      content: FutureBuilder<Map<String,dynamic>>(
          future: getAlbumList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if(snapshot.data['stat'] == 'fail') {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text('Failed to load albums'),
                    ),
                    Text(snapshot.data['result']),
                  ],
                );
              }
              CategoryModel root = _createAlbumTree(snapshot);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SingleChildScrollView(
                  child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(widget.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).textTheme.subtitle1.color ,fontSize: 16),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).inputDecorationTheme.fillColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListView.builder(
                            itemCount: 1,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return TreeViewNode(
                                node: root,
                                catId: widget.catId,
                                catName: widget.catName,
                                isImage: widget.isImage,
                                isRoot: true,
                                onSelected: widget.onSelected,
                              );
                            },
                          ),
                        ),
                      ]
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
      ),
    );
  }
}