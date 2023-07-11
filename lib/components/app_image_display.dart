import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/network/api_client.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageNetworkDisplay extends StatefulWidget {
  const ImageNetworkDisplay({
    Key? key,
    this.imageUrl,
    this.fit,
  }) : super(key: key);

  final String? imageUrl;
  final BoxFit? fit;

  @override
  State<ImageNetworkDisplay> createState() => _ImageNetworkDisplayState();
}

class _ImageNetworkDisplayState extends State<ImageNetworkDisplay> {
  late final Future<Map<String, String>> _headers;

  @override
  initState() {
    super.initState();
    _headers = _getHeaders();
  }

  Future<Map<String, String>> _getHeaders() async {
    String? serverUrl = appPreferences.getString(Preferences.serverUrlKey);

    if (serverUrl == null) return {};

    // Get server cookies
    List<Cookie> cookies =
        await ApiClient.cookieJar.loadForRequest(Uri.parse(serverUrl));
    String cookiesStr =
        cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');

    // Get HTTP Basic id
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? basicAuth;
    // Fetch only if enabled
    if (Preferences.getEnableBasicAuth) {
      String? username = prefs.getString(Preferences.basicUsernameKey) ?? '';
      String? password = prefs.getString(Preferences.basicPasswordKey) ?? '';
      basicAuth = "Basic ${base64.encode(utf8.encode('$username:$password'))}";
    }

    return {
      HttpHeaders.cookieHeader: cookiesStr,
      if (basicAuth != null) 'Authorization': basicAuth,
    };
  }

  void _checkMemory() {
    ImageCache imageCache = PaintingBinding.instance.imageCache;
    if (imageCache.liveImageCount >= Settings.maxCacheLiveImages) {
      imageCache.clear();
      imageCache.clearLiveImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null) {
      return _buildNoImageWidget(context);
    }
    _checkMemory();
    return FutureBuilder<Map<String, String>>(
        future: _headers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return LayoutBuilder(builder: (context, constraints) {
              double? cacheWidth =
                  constraints.maxWidth.isInfinite ? constraints.maxWidth : null;
              double? cacheHeight = constraints.maxHeight.isInfinite
                  ? constraints.maxHeight
                  : null;
              return CachedNetworkImage(
                imageUrl: widget.imageUrl!,
                fadeInDuration: const Duration(milliseconds: 300),
                fit: widget.fit ?? BoxFit.cover,
                httpHeaders: snapshot.data!,
                memCacheWidth: cacheWidth?.floor(),
                memCacheHeight: cacheHeight?.floor(),
                imageBuilder: (context, provider) => Image(
                  image: provider,
                  fit: widget.fit ?? BoxFit.cover,
                  errorBuilder: (context, o, s) {
                    debugPrint("$o\n$s");
                    return _buildErrorWidget(context, widget.imageUrl, o);
                  },
                ),
                progressIndicatorBuilder: _buildProgressIndicator,
                errorWidget: _buildErrorWidget,
              );
            });
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(context);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    String url,
    DownloadProgress download,
  ) {
    if (download.downloaded >= (download.totalSize ?? 0)) {
      return const SizedBox();
    }
    return Center(
      child: CircularProgressIndicator(
        value: download.progress,
      ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context, [
    String? url,
    dynamic error,
  ]) {
    debugPrint("[$url!] $error");
    return FittedBox(
      fit: BoxFit.cover,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }

  Widget _buildNoImageWidget(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: const Icon(Icons.image_not_supported),
      ),
    );
  }
}
