import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/data/datasources/local/preferences_datasource.dart';
import 'package:piwigo_ng/core/extensions/api_preferences_extension.dart';
import 'package:piwigo_ng/network/api_client.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/settings.dart';

class CustomNetworkImage extends StatefulWidget {
  const CustomNetworkImage({
    super.key,
    this.imageUrl,
    this.fit,
  });

  final String? imageUrl;
  final BoxFit? fit;

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage> with AppPreferencesMixin {
  late final Future<Map<String, String>> _headers;

  @override
  initState() {
    super.initState();
    _headers = _getHeaders();
  }

  Future<Map<String, String>> _getHeaders() async {
    String? serverUrl = prefs.instance.getString(Preferences.serverUrlKey);

    if (serverUrl == null) return <String, String>{};

    // Get server cookies
    List<Cookie> cookies = await ApiClient.cookieJar.loadForRequest(Uri.parse(serverUrl));
    String cookiesStr = cookies.map((Cookie cookie) => '${cookie.name}=${cookie.value}').join('; ');

    // Get HTTP Basic id
    String? basicAuth = prefs.apiBasicHeader;

    return <String, String>{
      HttpHeaders.cookieHeader: cookiesStr,
      if (basicAuth != null) 'Authorization': basicAuth,
    };
  }

  void _checkMemory() {
    ImageCache imageCache = PaintingBinding.instance.imageCache;
    if (imageCache.liveImageCount >= Settings.maxCacheLiveImages) {
      imageCache
        ..clear()
        ..clearLiveImages();
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
      builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
        if (snapshot.hasData) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double? cacheWidth = constraints.maxWidth.isInfinite ? constraints.maxWidth : null;
              double? cacheHeight = constraints.maxHeight.isInfinite ? constraints.maxHeight : null;
              return CachedNetworkImage(
                imageUrl: widget.imageUrl!,
                fadeInDuration: const Duration(milliseconds: 300),
                fit: widget.fit ?? BoxFit.cover,
                httpHeaders: snapshot.data!,
                memCacheWidth: cacheWidth?.floor(),
                memCacheHeight: cacheHeight?.floor(),
                imageBuilder: (BuildContext context, ImageProvider<Object> provider) => Image(
                  image: provider,
                  fit: widget.fit ?? BoxFit.cover,
                  errorBuilder: (BuildContext context, Object o, StackTrace? s) {
                    debugPrint('$o\n$s');
                    return _buildErrorWidget(context, widget.imageUrl, o);
                  },
                ),
                progressIndicatorBuilder: _buildProgressIndicator,
                errorWidget: _buildErrorWidget,
              );
            },
          );
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(context);
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
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
    debugPrint('[$url!] $error');
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
