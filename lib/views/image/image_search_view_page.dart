import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final DragSelectGridViewController _controller =
      DragSelectGridViewController();
  late String _searchText;

  @override
  void initState() {
    _searchText = _searchController.text;
    _controller.addListener(() => setState(() {}));
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      Future.delayed(const Duration(milliseconds: 300)).then(
        (value) => FocusScope.of(context).requestFocus(_focusNode),
      );
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {}

  void _onImagePressed(int index) {
    if (!_controller.value.isSelecting) {
      print('open $index');
    }
  }

  Future<bool> _onWillPop() async {
    if (_controller.value.isSelecting) {
      _controller.clear();
      return false;
    }
    setState(() {
      _searchText = '';
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                titleSpacing: 0.0,
                pinned: true,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: _buildAppBarLeading(),
                title: Hero(
                  tag: 'search-bar',
                  child: Material(
                    color: Colors.transparent,
                    child: AppField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      icon: const Icon(Icons.search),
                      hint: "Search...",
                      onChanged: (value) => setState(() {
                        _searchText = value;
                      }),
                      onFieldSubmitted: (value) {
                        if (value.isEmpty) Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                actions: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.ease,
                    width: _controller.value.isSelecting ? kToolbarHeight : 16,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.ease,
                      offset: _controller.value.isSelecting
                          ? Offset.zero
                          : const Offset(1, 0),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: DragSelectGridView(
                  gridController: _controller,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchText.isEmpty ? 0 : 64,
                  itemBuilder: (context, index, selected) {
                    return ImageCard(
                      selected: selected,
                      onPressed: () => _onImagePressed(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    const Duration duration = Duration(milliseconds: 200);
    const Curve curve = Curves.ease;
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      height: _controller.value.isSelecting ? kToolbarHeight : 0.0,
      child: AnimatedSlide(
        duration: duration,
        curve: curve,
        offset:
            _controller.value.isSelecting ? Offset.zero : const Offset(0, 1),
        child: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5,
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarLeading() {
    const Duration duration = Duration(milliseconds: 200);
    const Curve curve = Curves.ease;
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedScale(
            duration: duration,
            curve: curve,
            scale: _controller.value.isSelecting ? 0.5 : 1,
            child: AnimatedOpacity(
              duration: duration,
              curve: curve,
              opacity: _controller.value.isSelecting ? 0 : 1,
              child: const Icon(Icons.arrow_back),
            ),
          ),
          AnimatedScale(
            duration: duration,
            curve: curve,
            scale: _controller.value.isSelecting ? 1 : 0.5,
            child: AnimatedOpacity(
              duration: duration,
              curve: curve,
              opacity: _controller.value.isSelecting ? 1 : 0,
              child: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
