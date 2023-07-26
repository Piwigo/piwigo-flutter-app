import 'package:flutter/material.dart';
import 'package:piwigo_ng/components/sections/form_section.dart';
import 'package:piwigo_ng/utils/localizations.dart';

class SelectModelList<T> extends StatefulWidget {
  const SelectModelList({
    Key? key,
    this.selected = const [],
    this.unselected = const [],
    required this.itemBuilder,
    this.onSelect,
    this.onDeselect,
  }) : super(key: key);

  final List<T> selected;
  final List<T> unselected;
  final Widget Function(T) itemBuilder;
  final int Function(T)? onSelect;
  final int Function(T)? onDeselect;

  @override
  State<SelectModelList<T>> createState() => _SelectModelListState<T>();
}

class _SelectModelListState<T> extends State<SelectModelList<T>> {
  final GlobalKey<AnimatedListState> _selectedListKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _unselectedListKey =
      GlobalKey<AnimatedListState>();

  void _onTapItem(T item) {
    if (widget.selected.contains(item)) {
      _onDeselect(item);
    } else {
      _onSelect(item);
    }
  }

  void _onSelect(T item) async {
    int oldIndex = widget.unselected.indexOf(item);
    _unselectedListKey.currentState?.removeItem(
      oldIndex,
      (_, animation) => _buildItem(item, animation, false),
      duration: const Duration(milliseconds: 150),
    );

    int? newIndex = widget.onSelect?.call(item);
    newIndex ??= widget.selected.indexOf(item);
    _selectedListKey.currentState?.insertItem(newIndex);
  }

  void _onDeselect(T item) async {
    int oldIndex = widget.selected.indexOf(item);
    _selectedListKey.currentState?.removeItem(
      oldIndex,
      (_, animation) => _buildItem(item, animation, true),
      duration: const Duration(milliseconds: 150),
    );

    int? newIndex = widget.onDeselect?.call(item);
    await Future.delayed(const Duration(milliseconds: 100));
    newIndex ??= widget.unselected.indexOf(item);
    _unselectedListKey.currentState?.insertItem(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSelectedList,
        _buildUnselectedList,
      ],
    );
  }

  Widget get _buildSelectedList {
    return FormSection(
      title: appStrings.tagsHeader_selected,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Material(
          color: Theme.of(context).cardColor,
          child: AnimatedList(
            key: _selectedListKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: widget.selected.length,
            itemBuilder: (context, index, animation) {
              T item = widget.selected[index];
              return _buildItem(item, animation, true);
            },
          ),
        ),
      ),
    );
  }

  Widget get _buildUnselectedList {
    return FormSection(
      title: appStrings.tagsHeader_notSelected,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Material(
          color: Theme.of(context).cardColor,
          child: AnimatedList(
            key: _unselectedListKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: widget.unselected.length,
            itemBuilder: (context, index, animation) {
              T item = widget.unselected[index];
              return _buildItem(item, animation, false);
            },
          ),
        ),
      ),
    );
  }

  _buildItem(T item, Animation<double> animation, bool selected) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        key: ObjectKey(item),
        visualDensity: VisualDensity.compact,
        shape: Border(
          bottom: BorderSide(color: Theme.of(context).scaffoldBackgroundColor),
        ),
        title: widget.itemBuilder(item),
        trailing: selected
            ? Icon(Icons.remove_circle_outline, color: Colors.red)
            : Icon(Icons.add_circle_outline, color: Colors.green),
        onTap: () => _onTapItem(item),
      ),
    );
  }
}
