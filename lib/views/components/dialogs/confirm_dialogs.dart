import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/constants/SettingsConstants.dart';
import 'package:piwigo_ng/services/OrientationService.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({Key key, this.content, this.yes, this.no}) : super(key: key);
  final String content;
  final Widget yes;
  final Widget no;

  double _getWidth(context) {
    if(isPortrait(context)) {
      return MediaQuery.of(context).size.width > Constants.CONFIRM_DIALOG_MAX_WIDTH
          ? Constants.CONFIRM_DIALOG_MAX_WIDTH : MediaQuery.of(context).size.width;
    }
    return MediaQuery.of(context).size.height > Constants.CONFIRM_DIALOG_MAX_WIDTH
        ? Constants.CONFIRM_DIALOG_MAX_WIDTH : MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        insetPadding: EdgeInsets.zero,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: _getWidth(context),
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                children: [
                  Text((content != null) ? '$content'
                      : appStrings(context).deleteCategoryConfirm_title,
                    softWrap: true,
                    maxLines: 5,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                  Divider(height: 40),
                  InkWell(
                    child: Container(
                      child: Center(
                        child: yes,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              child: Container(
                width: _getWidth(context),
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Center(
                    child: no,
                ),
              ),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
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
  final Widget no;

  double _getWidth(context) {
    if(isPortrait(context)) {
      return MediaQuery.of(context).size.width > Constants.CONFIRM_DIALOG_MAX_WIDTH ?
      Constants.CONFIRM_DIALOG_MAX_WIDTH : MediaQuery.of(context).size.width;
    }
    return MediaQuery.of(context).size.height > Constants.CONFIRM_DIALOG_MAX_WIDTH ?
    Constants.CONFIRM_DIALOG_MAX_WIDTH : MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actionsRow = [];
    actions.forEach((action) {
      actionsRow.add(InkWell(
        onTap: () => Navigator.pop(context, actions.indexOf(action)),
        child: Container(
          width: double.infinity,
          child: Center(
            child: action,
          ),
        )
      ));
      if(action != actions.last) actionsRow.add(Divider(height: 20.0));
    });

    return WillPopScope(
      child: GestureDetector(
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          insetPadding: EdgeInsets.zero,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: _getWidth(context),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(
                  children: [
                    Text(
                      (content != null) ? '$content' : appStrings(context).deleteCategoryConfirm_title,
                      softWrap: true,
                      // maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                    Divider(height: 20.0),
                    Column(children: actionsRow),
                  ],
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Center(
                    child: no,
                  ),
                ),
                onTap: () => Navigator.pop(context, -1),
              ),
            ]
          ),
        ),
        onTap: () => Navigator.pop(context, -1),
      ),
      onWillPop: () async {
        Navigator.pop(context, -1);
        return true;
      },
    );
  }
}

class MultiConfirmBottomSheet extends StatefulWidget {
  const MultiConfirmBottomSheet({Key key, this.content, this.actions, this.no}) : super(key: key);

  final String content;
  final List<Widget> actions;
  final Widget no;

  @override
  _MultiConfirmBottomSheetState createState() => _MultiConfirmBottomSheetState();
}
class _MultiConfirmBottomSheetState extends State<MultiConfirmBottomSheet> with TickerProviderStateMixin {

  double _getWidth(context) {
    if(isPortrait(context)) {
      return MediaQuery.of(context).size.width > Constants.CONFIRM_DIALOG_MAX_WIDTH ?
      Constants.CONFIRM_DIALOG_MAX_WIDTH : MediaQuery.of(context).size.width;
    }
    return MediaQuery.of(context).size.height > Constants.CONFIRM_DIALOG_MAX_WIDTH ?
    Constants.CONFIRM_DIALOG_MAX_WIDTH : MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actionsRow = [];
    widget.actions.forEach((action) {
      actionsRow.add(InkWell(
          onTap: () => Navigator.pop(context, widget.actions.indexOf(action)),
          child: Container(
            width: double.infinity,
            child: Center(
              child: action,
            ),
          )
      ));
      if(action != widget.actions.last) actionsRow.add(Divider(height: 30.0));
    });

    return WillPopScope(
      child: BottomSheet(
        animationController: AnimationController(vsync: this),
        enableDrag: false,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
                children: [
                  Container(
                    width: _getWidth(context),
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: Column(
                      children: [
                        widget.content != null ? Column(
                          children: [
                            Text(
                              widget.content ?? appStrings(context).deleteCategoryConfirm_title,
                              softWrap: true,
                              // maxLines: 3,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                            ),
                            Divider(height: 30.0),
                          ],
                        ) : SizedBox(),
                        Column(children: actionsRow),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    child: Container(
                      width: _getWidth(context),
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Center(
                        child: widget.no,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, -1),
                  ),
                ]
            ),
          );
        },
        onClosing: () => Navigator.pop(context, -1),
      ),
      onWillPop: () async {
        Navigator.pop(context, -1);
        return true;
      },
    );
  }
}

class DialogButtonText extends StatelessWidget {
  const DialogButtonText(this.text, {Key key, this.color = Colors.black}) : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 16, color: color), maxLines: 1);
  }
}



Future<bool> confirmDeleteDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yes: DialogButtonText(appStrings(context).deleteCategoryConfirm_deleteButton, color: Colors.red),
      no: DialogButtonText(appStrings(context).alertCancelButton,
          color: Theme.of(context).disabledColor),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<int> confirmDeleteAlbumWithImagesDialog(context, {content = '', count = 0}) async {
  final int confirm = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => MultiConfirmBottomSheet(
      content: content,
      no: DialogButtonText(appStrings(context).alertCancelButton,
          color: Theme.of(context).disabledColor),
      actions: <Widget>[
        DialogButtonText(appStrings(context).deleteCategory_noImages,
            color: Theme.of(context).colorScheme.primary),
        DialogButtonText(appStrings(context).deleteCategory_orphanedImages, color: Colors.red),
        DialogButtonText(appStrings(context).deleteCategory_allImages(count), color: Colors.red),
      ],
    ),
  );

  return (confirm != null) ? confirm : -1;
}

Future<int> confirmRemoveImagesFromAlbumDialog(context, {content = '', count = 0}) async {
  final int confirm = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => MultiConfirmBottomSheet(
      content: content,
      no: DialogButtonText(appStrings(context).alertCancelButton,
          color: Theme.of(context).disabledColor),
      actions: <Widget>[
        DialogButtonText(appStrings(context).deleteCategoryConfirm_deleteButton, color: Colors.red),
        DialogButtonText(appStrings(context).removeSingleImage_title,
          color: Theme.of(context).colorScheme.primary),
      ],
    ),
  );

  return (confirm != null) ? confirm : -1;
}

Future<bool> confirmRemoveSelectionDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yes: DialogButtonText(appStrings(context).alertRemoveButton, color: Colors.red),
      no: DialogButtonText(appStrings(context).alertCancelButton,
          color: Theme.of(context).disabledColor),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmDownloadDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yes: DialogButtonText(appStrings(context).imageOptions_download,
          color: Theme.of(context).colorScheme.primary),
      no: DialogButtonText(appStrings(context).alertCancelButton,
          color: Theme.of(context).disabledColor),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmMoveDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yes: DialogButtonText(appStrings(context).alertMoveButton,
          color: Theme.of(context).colorScheme.primary),
      no: DialogButtonText(appStrings(context).alertCancelButton,
          color: Theme.of(context).disabledColor),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<bool> confirmAssignDialog(context, {content = ''}) async {
  final bool isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      content: content,
      yes: DialogButtonText(appStrings(context).alertCopyButton,
          color: Theme.of(context).colorScheme.primary),
      no: DialogButtonText(appStrings(context).alertCancelButton,
          color: Theme.of(context).disabledColor),
    ),
  );

  return (isConfirm != null) ? isConfirm : false;
}

Future<int> chooseMoveCopyImage(context, {content = ''}) async {
  final int confirm = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => MultiConfirmBottomSheet(
      // content: content,
      no: DialogButtonText(appStrings(context).alertCancelButton,
          color: Theme.of(context).disabledColor),
      actions: <Widget>[
        DialogButtonText(appStrings(context).moveImage_title,
            color: Theme.of(context).colorScheme.primary),
        DialogButtonText(appStrings(context).copyImage_title,
            color: Theme.of(context).colorScheme.primary),
      ],
    ),
  );

  return (confirm != null) ? confirm : -1;
}