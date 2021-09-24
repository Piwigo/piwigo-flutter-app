import 'package:flutter/material.dart';
import 'package:piwigo_ng/api/CategoryAPI.dart';
import 'package:piwigo_ng/model/CategoryModel.dart';
import 'package:piwigo_ng/views/components/buttons.dart';

void addCatRecursive(List<int> rank, CategoryModel cat, CategoryModel inputCat) {
  if(rank.length > 1) {
    CategoryModel nextInputCat = inputCat.children.elementAt(rank.first-1);
    rank.removeAt(0);
    addCatRecursive(rank, cat, nextInputCat);
  } else {
    inputCat.children.add(cat);
  }
}

class TreeViewNode extends StatefulWidget {
  const TreeViewNode({
    Key key,
    this.node,
    this.catId = "0",
    this.catName = "",
    this.isImage = false,
    this.isRoot = false,
    this.isExpanded = false,
    this.onSelected,
    this.indentIndex = 0,
  }) : super(key: key);

  final CategoryModel node;
  final String catId;
  final String catName;
  final bool isImage;
  final bool isRoot;
  final bool isExpanded;
  final Function(CategoryModel) onSelected;
  final int indentIndex;

  @override
  _TreeViewNodeState createState() => _TreeViewNodeState();
}
class _TreeViewNodeState extends State<TreeViewNode> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  AnimationController _controller;
  Animation<double> _heightFactor;

  @override
  initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeIn));
    _isExpanded = widget.isExpanded;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TreeViewNode oldWidget) {
    if (widget.isExpanded != oldWidget.isExpanded) {
      setState(() {
        _isExpanded = widget.isExpanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse().then<void>((void value) {
            if (!mounted) return;
            setState(() {});
          });
        }
      });
    } else if (widget.node != oldWidget.node) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  bool _isParentCategory() {
    return widget.node.children.map((e) => e.id).contains(widget.catId);
  }
  bool _isCurrentCategory() {
    return widget.node.id == widget.catId;
  }
  bool _isTappable() {
    if(widget.isImage) {
      return !widget.isRoot && !_isCurrentCategory();
    }
    return !_isParentCategory() && !_isCurrentCategory();
  }
  void _handleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildNode() {
    return GestureDetector(
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
            widget.node.children.length > 0 && !_isCurrentCategory() ? InkWell(
              onTap: _handleExpand,
              child: Row(
                children: [
                  Text('${widget.node.children.length}...', style: TextStyle(
                    fontSize: 16,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed =
        (!_isExpanded || !widget.isExpanded) && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (BuildContext context, Widget child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildNode(),
            widget.node.children.length > 0 && _isExpanded ? Divider(
              indent: 10.0,
              endIndent: 0.0,
              height: 1.0,
            ) : SizedBox(),
            ClipRect(
              child: Align(
                heightFactor: _heightFactor.value,
                child: child,
              ),
            ),
          ],
        );
      },
      child: closed ? null : Container(
        child: ListView.separated(
          itemCount: widget.node.children.length,
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
      ),
    );
  }
}

