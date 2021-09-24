import 'package:flutter/material.dart';
import 'package:piwigo_ng/services/OrientationService.dart';

import 'package:piwigo_ng/views/components/custom_shapes.dart';


class PiwigoDialog extends StatelessWidget {
  const PiwigoDialog({Key key,this.title = "", this.content, this.width, this.height}) : super(key: key);

  final String title;
  final Widget content;
  final double width;
  final double height;

  double _getWidth(context) {
    if(isPortrait(context)) {
      return MediaQuery.of(context).size.width*3/4;
    }
    return MediaQuery.of(context).size.height*3/4;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(10),
      child: Container(
        child: Stack(
          children: [
            height != null ?
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: ShapeDecoration(
                shape: DialogBackgroundShape(radius: 25),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              width: width ?? _getWidth(context),
              height: height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DialogHeader(title: title),
                    content,
                  ],
                ),
              ),
            ) : Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: ShapeDecoration(
                shape: DialogBackgroundShape(radius: 25),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              width: width ?? _getWidth(context),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DialogHeader(title: title),
                    content,
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0.0,
              top: 0.0,
              child: GestureDetector(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogHeader extends StatelessWidget {
  const DialogHeader({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /*
        Align(
          alignment: Alignment.topLeft,
          child: InkResponse(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: CircleAvatar(
              child: Icon(Icons.cancel, color: Theme.of(context.errorColor),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
         */
        Container(
          padding: EdgeInsets.all(5.0),
          alignment: Alignment.center,
          child: Text(title, style: Theme.of(context).textTheme.headline4),
        ),
      ],
    );
  }
}