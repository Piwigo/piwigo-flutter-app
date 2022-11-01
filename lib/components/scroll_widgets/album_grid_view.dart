import 'dart:math';

import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/cards/album_card.dart';
import 'package:piwigo_ng/models/album_model.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';

class AlbumGridView extends StatelessWidget {
  const AlbumGridView({
    Key? key,
    this.albumList = const [],
    this.onTap,
    this.padding,
  }) : super(key: key);

  final List<AlbumModel> albumList;
  final Function(AlbumModel)? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: Settings.defaultAlbumGridSize,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: AlbumCard.kAlbumRatio,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: albumList.length,
      itemBuilder: (context, index) {
        AlbumModel album = albumList[index];
        return AlbumCard(
          album: album,
          onTap: () {
            if (onTap != null) onTap!(album);
          },
        );
      },
    );
  }
}

class ExampleAlbumGridView extends StatelessWidget {
  const ExampleAlbumGridView({
    Key? key,
    this.albumThumbnailSize = Settings.defaultAlbumThumbnailSize,
  }) : super(key: key);

  final String albumThumbnailSize;

  List<AlbumModel> get _exampleAlbumList {
    return [
      AlbumModel(
        id: 0,
        name: 'weird_cat',
        comment: appStrings.createNewAlbumDescription_noDescription,
        urlRepresentative: 'assets/example/weird_cat/$albumThumbnailSize.jpg',
      ),
      AlbumModel(
        id: 0,
        name: 'weird_cat',
        comment: appStrings.createNewAlbumDescription_noDescription,
        urlRepresentative: 'assets/example/weird_cat/$albumThumbnailSize.jpg',
      ),
      AlbumModel(
        id: 0,
        name: 'weird_cat',
        comment: appStrings.createNewAlbumDescription_noDescription,
        urlRepresentative: 'assets/example/weird_cat/$albumThumbnailSize.jpg',
      ),
      AlbumModel(
        id: 0,
        name: 'weird_cat',
        comment: appStrings.createNewAlbumDescription_noDescription,
        urlRepresentative: 'assets/example/weird_cat/$albumThumbnailSize.jpg',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double nbPerRow = constraints.maxWidth / Settings.defaultAlbumGridSize;
      final int nbAlbums = max(nbPerRow.ceil(), 1);
      return GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: Settings.defaultAlbumGridSize,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: AlbumCard.kAlbumRatio,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: nbAlbums,
        itemBuilder: (context, index) {
          AlbumModel album = _exampleAlbumList[index];
          return AlbumCard(
            album: album,
            example: true,
            showActions: false,
          );
        },
      );
    });
  }
}
