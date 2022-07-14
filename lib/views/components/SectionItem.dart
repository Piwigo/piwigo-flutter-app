import 'package:flutter/material.dart';

class SectionItem extends StatelessWidget {
  const SectionItem(this.left, this.right, {Key key, this.options, this.isEnd = false, this.onTap}) : super(key: key);

  final Widget left;
  final Widget right;
  final List<Widget> options;
  final bool isEnd;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class SectionItemSingle extends StatelessWidget {
  const SectionItemSingle(this.content, {Key key, this.isEnd = false}) : super(key: key);

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