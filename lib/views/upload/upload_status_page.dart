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
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 5.0,
        title: Text(
          appStrings.uploadList_title,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() {
          _page = page;
        }),
        children: [
          _buildUploadList,
          _buildHistoryList,
        ],
      ),
      floatingActionButton: ScrollUpFloatingButton(
        controller: _scrollController,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        onTap: (index) => _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: appStrings.uploadList_uploading,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: appStrings.uploadList_history,
          ),
        ],
      ),
    );
  }

  Widget get _buildUploadList {
    return Consumer<UploadNotifier>(builder: (context, uploadNotifier, child) {
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
    });
  }

  Widget get _buildHistoryList {
    return Consumer<UploadNotifier>(builder: (context, uploadNotifier, child) {
      if (uploadNotifier.uploadHistoryList.isEmpty) {
        return Center(
          child: Text(appStrings.noImages),
        );
      }
      return ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 8.0),
        itemCount: uploadNotifier.uploadHistoryList.length,
        itemBuilder: (context, index) {
          UploadItem item = uploadNotifier.uploadHistoryList[index];
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
            subtitle: Builder(builder: (context) {
              if (item.error) {
                return Text(appStrings.errorHUD_label);
              } else if (item.cancelToken.isCancelled) {
                return Text(appStrings.uploadCancelled_title);
              }
              return Text(appStrings.completeHUD_label);
            }),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      );
    });
  }
}

class ScrollUpFloatingButton extends AnimatedWidget {
  const ScrollUpFloatingButton({
    Key? key,
    required this.controller,
  }) : super(key: key, listenable: controller);

  static const Duration showDuration = Duration(milliseconds: 300);
  static const Duration scrollDuration = Duration(milliseconds: 700);
  static const Curve showCurve = Curves.ease;

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    bool isHidden = !controller.hasClients || controller.offset < kToolbarHeight;
    return AnimatedScale(
      duration: showDuration,
      curve: showCurve,
      scale: isHidden ? 0.0 : 1.0,
      child: AnimatedOpacity(
        duration: showDuration,
        curve: showCurve,
        opacity: isHidden ? 0.0 : 1.0,
        child: FloatingActionButton(
          backgroundColor: Colors.grey.withOpacity(0.8),
          onPressed: () => controller.animateTo(
            0.0,
            duration: scrollDuration,
            curve: showCurve,
          ),
          child: Icon(Icons.arrow_upward),
        ),
      ),
    );
  }
}
