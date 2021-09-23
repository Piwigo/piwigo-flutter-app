import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/model/CategoryModel.dart';
import 'package:piwigo_ng/views/components/Buttons.dart';

void addCatRecursive(List<int> rank, CategoryModel cat, CategoryModel inputCat) {
  if(rank.length > 1) {
    CategoryModel nextInputCat = inputCat.children.elementAt(rank.first-1);
    rank.removeAt(0);
    addCatRecursive(rank, cat, nextInputCat);
  } else {
    inputCat.children.add(cat);
  }
}

Future<dynamic> moveCategoryModalBottomSheet(context, String catId, String catName, bool isImage, Function(CategoryModel) onSelected) async {
  await showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (BuildContext bc) {
      return StatefulBuilder(
        builder: (BuildContext context, setState) =>
          FutureBuilder<Map<String,dynamic>>(
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
                CategoryModel root = CategoryModel("0", "root", fullname: "root");
                snapshot.data['result']['categories'].forEach((cat) {
                  List<int> rank = cat['global_rank'].split('.').map(int.parse).toList().cast<int>();
                  CategoryModel newCat = CategoryModel(cat['id'], cat['name'], comment: cat['comment'], nbImages: cat['nb_images'].toString(), fullname: cat['fullname'], status: cat['status']);
                  if(rank.length > 1) {
                    CategoryModel nextInputCat = root.children.elementAt(rank.first-1);
                    rank.removeAt(0);
                    addCatRecursive(rank, newCat, nextInputCat);
                  } else {
                    root.children.add(newCat);
                  }
                });
                return Container(
                  height: 500,
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(isImage? 'Move or Copy Image' : 'Move Album', style: Theme.of(context).textTheme.headline1,),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Choose an album', style: TextStyle(color: Theme.of(context).textTheme.subtitle1.color ,fontSize: 16)),
                        ),
                        GestureDetector(
                          onTap: root.children.map((e) => e.id).contains(catId) || isImage? () {} : () {onSelected(root);},
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
                              style: TextStyle(fontSize: 16, color: root.children.map((e) => e.id).contains(catId) || isImage? Theme.of(context).disabledColor : Colors.black)
                            ),
                          ),
                        ),
                        root.children.length > 0? categoryChildrenList(root.children, catId, catName, isImage, onSelected) : Container(),
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
  );
  return catId;
}

Widget categoryChildrenList(List<CategoryModel> nodes, String catId, String catName, bool isImage, Function(CategoryModel) onSelected) {
  int openedList = -1;

  return StatefulBuilder(
    builder: (BuildContext context, setState) => ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        CategoryModel item = nodes[index];
        if(item.id == catId && !isImage) {
          return Container();
        }
        return openedList == index || openedList == -1? Column(
          children: [
            GestureDetector(
              onTap: item.id == catId || (item.children.map((e) => e.id).contains(catId) && !isImage)? () {} : () {onSelected(item);},
              child: Container(
                margin: EdgeInsets.only(left: openedList == index? 0 : 10, top: openedList == index? 2 : 7),
                decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text('${item.name}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: item.id == catId || (item.children.map((e) => e.id).contains(catId) && !isImage)? Theme.of(context).disabledColor : Colors.black)
                      ),
                    ),
                    item.children.length > 0?
                    InkWell(
                      onTap: () {
                        setState(() {
                          if(openedList != index) {
                            openedList = index;
                          } else {
                            openedList = -1;
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: openedList == index ?
                            Icon(Icons.keyboard_arrow_up) :
                            Icon(Icons.keyboard_arrow_down)
                      ),
                    ) : Text(''),
                  ],
                ),
              ),
            ),
            item.children.length > 0 && openedList == index? categoryChildrenList(item.children, catId, catName, isImage, onSelected) : Container(),
          ],
        ) : Container();
      },
    ),
  );
}


class TreeViewNode extends StatefulWidget {
  const TreeViewNode({
    Key key,
    this.node,
    this.catId = "0",
    this.catName = "",
    this.isImage = false,
    this.isRoot = false,
    this.onSelected,
    this.indentIndex = 0,
  }) : super(key: key);

  final CategoryModel node;
  final String catId;
  final String catName;
  final bool isImage;
  final bool isRoot;
  final Function(CategoryModel) onSelected;
  final int indentIndex;

  @override
  _TreeViewNodeState createState() => _TreeViewNodeState();
}
class _TreeViewNodeState extends State<TreeViewNode> {
  bool _isExpanded = false;

  bool _isActualCategory() {
    return widget.node.children.map((e) => e.id).contains(widget.catId);
  }
  bool _isTappable() {
    if(widget.isImage) {
      return !widget.isRoot && widget.node.id != widget.catId;
    }
    return !_isActualCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isTappable() ? () {
              widget.onSelected(widget.node);
            } : null,
          child: Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10 + widget.indentIndex * 10.0,
                        vertical: 10
                    ),
                    child: Text('${widget.node.name}',
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(fontSize: 16,
                          color: _isTappable() ?
                          Colors.black : Theme.of(context).disabledColor,
                        )),
                  ),
                ),
                widget.node.children.length > 0 ? InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      Text('${widget.node.children.length}...', style: TextStyle(fontSize: 16,
                        color: Theme.of(context).iconTheme.color,
                      )),
                      Container(
                        padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                        child: AnimatedIconButton(
                          Icon(Icons.keyboard_arrow_right),
                          isActive: _isExpanded,
                        ),
                      ),
                    ],
                  ),
                ) : SizedBox(),
              ],
            ),
          ),
        ),
        widget.node.children.length > 0 && _isExpanded ? Divider(
          indent: 10.0,
          endIndent: 0.0,
          height: 1.0,
        ) : SizedBox(),
        ListView.separated(
            itemCount: _isExpanded ? widget.node.children.length : 0,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return TreeViewNode(
                node: widget.node.children[index],
                catId: widget.catId,
                catName: widget.catName,
                isImage: widget.isImage,
                onSelected: widget.onSelected,
                indentIndex: widget.indentIndex+1,
              );
            },
          separatorBuilder: (context, index) {
            return index == widget.node.children.length-1 ? SizedBox() : Divider(
              indent: 10.0,
              endIndent: 0.0,
              height: 1.0,
            );
          },
        ),
      ],
    );
  }
}

