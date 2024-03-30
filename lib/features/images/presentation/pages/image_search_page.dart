import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/fields/app_field.dart';
import 'package:piwigo_ng/core/utils/constants/hero_tags.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';

class ImageSearchPage extends StatefulWidget {
  const ImageSearchPage({super.key});

  @override
  State<ImageSearchPage> createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildSearchBar(context),
      );

  PreferredSizeWidget _buildSearchBar(BuildContext context) => AppBar(
        titleSpacing: 0.0,
        title: Hero(
          tag: HeroTags.imageSearchField,
          flightShuttleBuilder: (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            animation.addStatusListener((AnimationStatus status) {
              if (status == AnimationStatus.completed) {
                // the end of hero animation end
                Future<void>.delayed(
                  const Duration(milliseconds: 1),
                  () => _searchFocusNode.requestFocus(),
                );
              }
            });

            final Hero toHero = toHeroContext.widget as Hero;

            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                return toHero.child;
              },
            );
          },
          child: Material(
            color: Colors.transparent,
            child: AppField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              padding: const EdgeInsets.symmetric(
                vertical: UIConstants.paddingXSmall,
                horizontal: UIConstants.paddingSmall,
              ),
              prefix: const Icon(Icons.search),
              hint: "Search...",
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      );
}
