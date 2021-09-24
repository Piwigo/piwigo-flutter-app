import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({Key key, this.content, this.yes, this.no, this.yesColor}) : super(key: key);
  final String content;
  final Text yes;
  final Text no;
  final Color yesColor;

  double _getWidth(context) {
    if(isPortrait(context)) {
      return MediaQuery.of(context).size.width/2;
    }
    return MediaQuery.of(context).size.height/2;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: AlertDialog(
        contentPadding: EdgeInsets.all(10.0),
        backgroundColor: Colors.transparent,
        content: Container(
          width: _getWidth(context),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  alignment: Alignment.center,
                  child: Text(
                    (content != null) ? '$content' : appStrings(context).deleteCategoryConfirm_title,
                    softWrap: true,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).disabledColor,
                          ),
                          child: TextButton(
                            child: no,
                            onPressed: () => Navigator.pop(context, false),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: yesColor,
                          ),
                          child: TextButton(
                            child: yes,
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ),
                      ),
                    ]
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, false);
        return true;
      },
    );
  }
}

class MultiConfirmDialog extends StatelessWidget {
  const MultiConfirmDialog({Key key, this.content, this.actions, this.no}) : super(key: key);
  final String content;
  final List<Widget> actions;
  final Text no;

  @override
  Widget build(BuildContext context) {
    List<Widget> actionsRow = [];
    actions.forEach((action) {
      actionsRow.add(Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: TextButton(
          child: action,
          onPressed: () => Navigator.pop(context, actions.indexOf(action)),
        ),
      ));
      actionsRow.add(SizedBox(height: 10.0));
    });

    return WillPopScope(
      child: AlertDialog(
        contentPadding: EdgeInsets.all(10.0),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  alignment: Alignment.center,
                  child: Text(
                    (content != null) ? '$content' : appStrings(context).deleteCategoryConfirm_title,
                    softWrap: true,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Column(children: actionsRow),
                SizedBox(height: 10.0),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).disabledColor,
                  ),
                  child: TextButton(
                    child: no,
                    onPressed: () => Navigator.pop(context, -1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, -1);
        return true;
      },
    );
  }
}


Future<bool> confirmDeleteDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Colors.red,
      yes: Text(appStrings(context).deleteCategoryConfirm_deleteButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmRemoveSelectionDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Colors.red,
      yes: Text(appStrings(context).alertRemoveButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmDownloadDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Colors.blue,
      yes: Text(appStrings(context).imageOptions_download,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmMoveDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Theme.of(context).colorScheme.primary,
      yes: Text(appStrings(context).alertMoveButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmAssignDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yesColor: Theme.of(context).colorScheme.primary,
      yes: Text(appStrings(context).alertCopyButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
      no: Text(appStrings(context).alertCancelButton,
          style: TextStyle(fontSize: 16, color: Colors.white)
      ),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<int> chooseMoveCopyImage(context, {content = ''}) async {
  final int confirm = await showDialog<int>(
    context: context,
    builder: (_) => MultiConfirmDialog(
      content: content,
      no: Text(appStrings(context).alertCancelButton, style: TextStyle(fontSize: 16, color: Colors.white)),
      actions: <Widget>[
        Text(appStrings(context).moveImage_title, style: TextStyle(fontSize: 16, color: Colors.white)),
        Text(appStrings(context).copyImage_title, style: TextStyle(fontSize: 16, color: Colors.white)),
      ],
    ),
  );

  return (confirm != null) ? confirm : -1;
}