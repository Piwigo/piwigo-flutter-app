import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/router/app_router.dart';
import 'package:piwigo_ng/core/router/app_routes.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';
import 'package:piwigo_ng/features/albums/domain/entities/album_entity.dart';
import 'package:piwigo_ng/features/albums/presentation/blocs/album_content/album_content_bloc.dart';
import 'package:piwigo_ng/features/albums/presentation/widgets/album_card_widget.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/session_status/session_status_bloc.dart';
import 'package:piwigo_ng/features/images/domain/entities/image_entity.dart';
import 'package:piwigo_ng/features/images/presentation/widgets/image_card_widget.dart';

class AlbumContentWidget extends StatelessWidget with UserStatusMixin {
  const AlbumContentWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AlbumContentBloc, AlbumContentState>(
        builder: (BuildContext context, AlbumContentState state) => state.maybeWhen(
          orElse: () => _buildLoading(),
          failure: (Failure failure) => _buildError(context, failure),
          loading: (List<AlbumEntity>? albums) {
            if (albums == null) return _buildLoading();
            return _buildAlbumContent(context, albums, const <ImageEntity>[]);
          },
          success: (List<AlbumEntity> albums) => _buildAlbumContent(context, albums, const <ImageEntity>[]),
        ),
      );

  Widget _buildLoading() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildError(BuildContext context, Failure failure) => Center(
        child: Text(failure.getMessage(context)),
      );

  Widget _buildAlbumContent(BuildContext context, List<AlbumEntity> albums, List<ImageEntity> images) => Column(
        children: <Widget>[
          GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: AlbumCardWidget.maxWidth,
              mainAxisSpacing: UIConstants.paddingSmall,
              crossAxisSpacing: UIConstants.paddingSmall,
              childAspectRatio: AlbumCardWidget.sizeRatio,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: albums.length,
            itemBuilder: (BuildContext context, int index) {
              final AlbumEntity album = albums[index];
              return AlbumCardWidget(
                album: album,
                showActions: isAdmin(context),
                onTap: () => context.navigator.pushNamed(
                  AppRoutes.album,
                  arguments: PageRouteArguments.album(album: album),
                ),
              );
            },
          ),
          if (images.isNotEmpty && albums.isNotEmpty) const SizedBox(height: UIConstants.paddingSmall),
          ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            itemBuilder: (BuildContext context, int index) {
              final ImageEntity image = images[index];
              return ImageCardWidget(
                image: image,
              );
            },
          ),
          SizedBox(
            height: context.screenPadding.bottom + UIConstants.paddingMedium,
          ),
        ],
      );
}
