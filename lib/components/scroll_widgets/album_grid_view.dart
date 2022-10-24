import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/cards/album_card.dart';
import 'package:piwigo_ng/models/album_model.dart';

class AlbumGridView extends StatelessWidget {
  const AlbumGridView({
    Key? key,
    this.albumList = const [],
    this.onTap,
    this.padding,
    this.example = false,
  }) : super(key: key);

  final bool example;
  final List<AlbumModel> albumList;
  final Function(AlbumModel)? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400.0, // todo: use preferences
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
          example: example,
          onTap: () {
            if (onTap != null) onTap!(album);
          },
        );
      },
    );
  }
}
