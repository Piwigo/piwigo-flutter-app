import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:piwigo_ng/api/api_error.dart';
import 'package:piwigo_ng/api/images.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/page_routes.dart';

import '../../components/cards/image_card.dart';
import '../../components/fields/app_field.dart';

class ImageSearchViewPage extends StatefulWidget {
  const ImageSearchViewPage({Key? key}) : super(key: key);

  static const String routeName = '/images/search';

  @override
  State<ImageSearchViewPage> createState() => _ImageSearchViewPageState();
}

class _ImageSearchViewPageState extends State<ImageSearchViewPage> {
  final FocusNode _focusNode = FocusNode();
  String _searchText = '';

  late Future<ApiResult<List<ImageModel>>> _imageFuture;

  @override
  void initState() {
    super.initState();
    _getData();
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      Future.delayed(SlideUpPageRoute.duration).then(
        (value) => FocusScope.of(context).requestFocus(_focusNode),
      );
    });
  }

  void _getData() {
    setState(() {
      _imageFuture = searchImages(_searchText);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            _searchAppBar,
            SliverToBoxAdapter(
              child: _searchGrid,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _searchAppBar => SliverAppBar(
        pinned: true,
        centerTitle: true,
        titleSpacing: 0.0,
        leading: IconButton(
          onPressed: () {
            _focusNode.unfocus();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Hero(
          tag: 'search-bar',
          child: Material(
            color: Colors.transparent,
            child: AppField(
              focusNode: _focusNode,
              icon: const Icon(Icons.search),
              hint: "Search...",
              onChanged: (value) => setState(() {
                _searchText = value;
                _getData();
              }),
              onFieldSubmitted: (value) {
                if (value.isEmpty) Navigator.of(context).pop();
              },
            ),
          ),
        ),
        actions: [
          const SizedBox(width: 16),
        ],
      );

  Widget get _searchGrid => FutureBuilder<ApiResult<List<ImageModel>>>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.data!.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(appStrings.categoryImageList_noDataError),
                ),
              );
            }
            final List<ImageModel> searchList = snapshot.data!.data!;
            if (searchList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(appStrings.noImages),
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchList.length,
              itemBuilder: (context, index) {
                return ImageCard(
                  image: searchList[index],
                  onPressed: () {},
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      );
}
