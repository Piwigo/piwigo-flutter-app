import 'dart:math';

import 'package:flutter/material.dart';
import 'package:piwigo_ng/services/upload_notifier.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:provider/provider.dart';

class UploadStatusPage extends StatefulWidget {
  const UploadStatusPage({Key? key}) : super(key: key);

  static const String routeName = '/upload/status';

  @override
  State<UploadStatusPage> createState() => _UploadStatusPageState();
}

class _UploadStatusPageState extends State<UploadStatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 5.0,
        title: Text(
          appStrings.tabBar_upload,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Consumer<UploadNotifier>(builder: (context, uploadNotifier, child) {
        if (uploadNotifier.uploadList.isEmpty) {
          return Center(
            child: Text(appStrings.noImages),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          itemCount: uploadNotifier.uploadList.length,
          itemBuilder: (context, index) {
            UploadItem item = uploadNotifier.uploadList[index];
            return ListTile(
              dense: true,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(
                    item.file,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                item.file.path.split('/').last,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: StreamBuilder<double>(
                stream: item.progress.stream,
                initialData: 0.0,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return LinearProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                      value: min(snapshot.data!, 1.0),
                    );
                  }
                  return LinearProgressIndicator();
                },
              ),
              trailing: IconButton(
                onPressed: () {
                  item.cancelToken.cancel();
                  uploadNotifier.itemUploadCompleted(item);
                },
                icon: Icon(Icons.close),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
        );
      }),
    );
  }
}
