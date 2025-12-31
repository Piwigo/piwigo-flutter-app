import 'package:flutter/material.dart';

class FormSection extends StatelessWidget {
  const FormSection({
    Key? key,
    this.title,
    required this.child,
    this.margin,
    this.padding,
    this.actions = const [],
    this.onTapTitle,
    this.expanded,
    this.titlePadding,
  }) : super(key: key);

  final String? title;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final EdgeInsets? titlePadding;
  final Function()? onTapTitle;
  final bool? expanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapTitle,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: titlePadding ?? const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title!,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (expanded != null)
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.ease,
                              turns: expanded == false ? 0.25 : 0.75,
                              child: Icon(Icons.chevron_right),
                            ),
                        ],
                      ),
                    ),
                  ),
                  ...actions
                ],
              ),
            ),
          Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Builder(
              builder: (context) {
                if (expanded != null) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                    child: child,
                  );
                }
                return child;
              },
            ),
          ),
        ],
      ),
    );
  }
}
