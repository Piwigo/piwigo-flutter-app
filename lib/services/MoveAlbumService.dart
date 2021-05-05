import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/model/Category.dart';
import 'package:piwigo_ng/ui/SnackBars.dart';

Future<dynamic> moveCategoryModalBottomSheet(context, String catId, String catName) async {

  await showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (BuildContext bc) {
      return StatefulBuilder(
        builder: (BuildContext context, setState) =>
            FutureBuilder(
                future: getAlbumList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Category root = snapshot.data;
                    return Container(
                      height: 500,
                      padding: EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('Move Album', style: Theme.of(context).textTheme.headline1,),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text('Choose an album', style: TextStyle(color: Theme.of(context).textTheme.subtitle1.color ,fontSize: 16)),
                              ),
                              GestureDetector(
                                onTap: root.children.map((e) => e.id).contains(catId)? () {} : () async {
                                  if (await confirm(
                                    context,
                                    title: Text('Confirm'),
                                    content: Text('Move $catName to Root Album ?', softWrap: true, maxLines: 3),
                                    textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                                    textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
                                  )) {
                                    print('Move $catId to ${root.id}');
                                    var result = await moveCategory(catId, root.id);
                                    print(result);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        albumMovedSnackBar(catName, "Root Album"));
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.all(1),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).inputDecorationTheme.fillColor,
                                      borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text('${root.name}',
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: TextStyle(fontSize: 16, color: root.children.map((e) => e.id).contains(catId)? Theme.of(context).disabledColor : Colors.black)
                                  ),
                                ),
                              ),
                              root.children.length > 0? categoryChildrenList(root.children, catId, catName) : Container(),
                            ]
                        ),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }
            ),
      );
    }
  );
  return catId;
}

Widget categoryChildrenList(List<Category> nodes, String catId, String catName) {
  int openedList = -1;

  return StatefulBuilder(
    builder: (BuildContext context, setState) => ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        Category item = nodes[index];
        if(item.id == catId) {
          return Container();
        }
        return openedList == index || openedList == -1? Column(
          children: [
            GestureDetector(
              onTap: item.id == catId || item.children.map((e) => e.id).contains(catId)? () {} : () async {
                if (await confirm(
                  context,
                  title: Text('Confirm'),
                  content: Text('Move $catName to ${item.name} ?', softWrap: true, maxLines: 3),
                  textOK: Text('Yes', style: TextStyle(color: Color(0xff479900))),
                  textCancel: Text('No', style: TextStyle(color: Theme.of(context).errorColor)),
                )) {
                  print('Move $catId to ${item.id}');
                  var result = await moveCategory(catId, item.id);
                  print(result);
                  ScaffoldMessenger.of(context).showSnackBar(albumMovedSnackBar(catName, item.name));
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                margin: EdgeInsets.only(left: openedList == index? 0 : 10, top: openedList == index? 2 : 7),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(5),
                    // border: Border.all(color: Colors.grey, width: 1)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.name}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: item.children.map((e) => e.id).contains(catId)? Theme.of(context).disabledColor : Colors.black)
                      ),
                    ),
                    item.children.length > 0?
                    InkWell(
                      onTap: item.id == catId ? () {} : () {
                        setState(() {
                          if(openedList != index) {
                            openedList = index;
                          } else {
                            openedList = -1;
                          }
                        });
                      },
                      child: item.id != catId ? openedList == index? Icon(Icons.keyboard_arrow_up) : Icon(Icons.keyboard_arrow_down) : Icon(Icons.keyboard_arrow_down, color: Colors.grey,),
                    ) : Text(''),
                  ],
                ),
              ),
            ),
            item.children.length > 0 && openedList == index? categoryChildrenList(item.children, catId, catName) : Container(),
          ],
        ) : Container();
      },
    ),
  );
}

