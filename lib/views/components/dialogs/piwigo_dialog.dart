import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';

import 'package:piwigo_ng/views/components/custom_shapes.dart';


class PiwigoDialog extends StatelessWidget {
  const PiwigoDialog({Key key,this.title = "", this.content, this.width, this.height, this.action}) : super(key: key);

  final String title;
  final Widget content;
  final double width;
  final double height;
  final Widget action;

  double _getWidth(context) {
    if(isPortrait(context)) {
      return MediaQuery.of(context).size.width > Constants.confirmDialogMaxWidth ?
      MediaQuery.of(context).size.width*3/4 : MediaQuery.of(context).size.width;
    }
    return MediaQuery.of(context).size.height > Constants.confirmDialogMaxWidth ?
      MediaQuery.of(context).size.height*3/4 : MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(5.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: height != null ? Container(
              margin: EdgeInsets.all(20),
              decoration: ShapeDecoration(
                shape: DialogBackgroundShape(radius: 20),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              height: height,
              width: _getWidth(context),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DialogHeader(title: title, action: action),
                    Padding(
                      padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 20),
                      child: content,
                    ),
                  ],
                ),
              ),
            ) : Container(
            margin: EdgeInsets.all(20),
            decoration: ShapeDecoration(
              shape: DialogBackgroundShape(radius: 20),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            width: _getWidth(context),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogHeader(title: title, action: action),
                  Padding(
                    padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 20),
                    child: content,
                  ),
                ],
              ),
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
                  radius: 19.0,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DialogHeader extends StatelessWidget {
  const DialogHeader({Key key, this.title, this.action}) : super(key: key);

  final String title;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: action,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(title, style: Theme.of(context).textTheme.headline4),
          ),
        ],
      ),
    );
  }
}