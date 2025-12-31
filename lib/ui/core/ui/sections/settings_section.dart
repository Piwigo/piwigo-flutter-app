import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import '../fields/settings_field.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    Key? key,
    this.title,
    this.children = const [],
    this.margin,
    this.color,
  }) : super(key: key);

  final String? title;
  final List<Widget> children;
  final EdgeInsets? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).cardColor,
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: children.length,
                itemBuilder: (context, index) {
                  return children[index];
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                    thickness: 1,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSectionItem extends StatelessWidget {
  const SettingsSectionItem({
    Key? key,
    required this.child,
    this.title,
    this.color,
    this.disabled = false,
    this.expandedChild = false,
    this.padding,
  }) : super(key: key);

  final Widget child;
  final String? title;
  final Color? color;
  final bool disabled;
  final bool expandedChild;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
      ),
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
        child: Row(
          children: [
            if (title != null)
              Builder(builder: (context) {
                Widget titleWidget = Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 8.0,
                  ),
                  child: Text(
                    title!,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );

                if (expandedChild == true) return titleWidget;
                return Expanded(child: titleWidget);
              }),
            Builder(builder: (context) {
              if (title == null || expandedChild) return Expanded(child: child);
              return child;
            }),
          ],
        ),
      ),
    );
  }
}

class SettingsSectionItemInfo extends StatelessWidget {
  const SettingsSectionItemInfo({
    Key? key,
    this.text,
    this.title,
    this.child,
  }) : super(key: key);

  final String? title;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionItem(
      title: title,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Builder(builder: (context) {
          if (child != null) {
            return child!;
          }
          return Text(
            text ?? "",
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall,
          );
        }),
      ),
    );
  }
}

class SettingsSectionItemButton extends StatelessWidget {
  const SettingsSectionItemButton({
    Key? key,
    this.text,
    this.title,
    this.onPressed,
    this.disabled = false,
    this.icon,
  }) : super(key: key);

  final String? title;
  final String? text;
  final bool disabled;
  final Function()? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: SettingsSectionItem(
        title: title,
        disabled: disabled,
        expandedChild: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: ExtendedText(
                text ?? '',
                maxLines: 1,
                overflowWidget: TextOverflowWidget(
                  position: TextOverflowPosition.start,
                  child: Text(
                    "...",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Theme(
                data: ThemeData(
                  iconTheme: IconThemeData(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                child: Builder(builder: (context) {
                  if (icon != null) return icon!;
                  return const Icon(Icons.chevron_right);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsSectionItemSlider extends StatefulWidget {
  const SettingsSectionItemSlider({
    Key? key,
    this.text,
    this.title,
    required this.onChanged,
    this.min = 0.0,
    required this.max,
    required this.value,
    this.hint,
    this.divisions,
    this.enableField = true,
    this.textWidth,
  }) : super(key: key);

  final String? title;
  final String? text;
  final String? hint;
  final double min;
  final double max;
  final double value;
  final double? textWidth;
  final int? divisions;
  final bool enableField;
  final Function(double) onChanged;

  @override
  State<SettingsSectionItemSlider> createState() =>
      _SettingsSectionItemSliderState();
}

class _SettingsSectionItemSliderState extends State<SettingsSectionItemSlider> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  void _onOpenEditField() {
    if (!widget.enableField) return;
    setState(() {
      _controller.text = '${widget.value.round()}';
      _focusNode.requestFocus();
      _isEditing = true;
    });
  }

  double _onEditCheckStep(double value) {
    if (widget.divisions == null) return value;
    double step = (widget.max - widget.min) / widget.divisions!;
    double deltaStep = (value - widget.min) % step;
    if (deltaStep == 0) return value;
    if (deltaStep <= step / 2) {
      value -= deltaStep;
    } else {
      value += step - deltaStep;
    }
    return value;
  }

  void _onEditValue(String value) {
    try {
      double fieldValue = double.parse(value);
      fieldValue = _onEditCheckStep(fieldValue);
      if (fieldValue < widget.min) {
        fieldValue = widget.min;
      } else if (fieldValue > widget.max) {
        fieldValue = widget.max;
      }
      widget.onChanged(fieldValue);
    } catch (e) {
      widget.onChanged(widget.value);
    }
    setState(() {
      _focusNode.unfocus();
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionItem(
      title: widget.title,
      expandedChild: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width / 2,
          maxWidth: MediaQuery.of(context).size.width * 2 / 3,
        ),
        child: Builder(builder: (context) {
          if (_isEditing) {
            return Row(
              children: [
                Expanded(
                  child: SettingsField(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    controller: _controller,
                    focusNode: _focusNode,
                    hint: widget.hint,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: _onEditValue,
                  ),
                ),
                GestureDetector(
                  onTap: () => _onEditValue(_controller.text),
                  child: const Icon(Icons.check),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: Slider(
                  min: widget.min,
                  max: widget.max,
                  value: widget.value,
                  onChanged: widget.onChanged,
                  divisions:
                      widget.divisions ?? (widget.max - widget.min).round(),
                ),
              ),
              if (widget.text != null)
                GestureDetector(
                  onTap: _onOpenEditField,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: widget.textWidth ??
                          widget.max.toString().length * 2 * 6,
                      child: Text(
                        widget.text!,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class SettingsSectionItemSwitch extends StatelessWidget {
  const SettingsSectionItemSwitch({
    Key? key,
    this.title,
    this.onChanged,
    this.value = false,
  }) : super(key: key);

  final String? title;
  final bool value;
  final Function(bool)? onChanged;

  void _onSwitch() {
    if (onChanged != null) {
      onChanged!(!value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onSwitch,
      child: SettingsSectionItem(
        title: title,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Switch(
              onChanged: onChanged,
              value: value,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsSectionItemField extends StatefulWidget {
  const SettingsSectionItemField({
    Key? key,
    this.title,
    required this.onChanged,
    this.hint,
    required this.value,
    this.isObscure = false,
  }) : super(key: key);

  final String? title;
  final String? hint;
  final String value;
  final bool isObscure;
  final Function(String) onChanged;

  @override
  State<SettingsSectionItemField> createState() =>
      _SettingsSectionItemFieldState();
}

class _SettingsSectionItemFieldState extends State<SettingsSectionItemField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSectionItem(
      expandedChild: true,
      child: SettingsField(
        controller: _controller,
        hint: widget.hint,
        isObscure: widget.isObscure,
        onChanged: widget.onChanged,
      ),
    );
  }
}

class SettingsSectionButton extends StatelessWidget {
  const SettingsSectionButton({
    Key? key,
    this.onPressed,
    this.child,
    this.color,
    this.padding,
  }) : super(key: key);

  final EdgeInsetsGeometry? padding;
  final Function()? onPressed;
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SettingsSectionItem(
        padding: padding,
        color: color,
        child: child ?? const SizedBox(),
      ),
    );
  }
}

class SettingsSectionDropdown<T> extends StatelessWidget {
  const SettingsSectionDropdown({
    Key? key,
    this.color,
    this.padding,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    this.title,
    this.selectedItemBuilder,
  }) : super(key: key);

  final EdgeInsetsGeometry? padding;
  final Color? color;
  final List<DropdownMenuItem<T>> items;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final T value;
  final Function(T?) onChanged;
  final String? hint;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionItem(
      padding: padding,
      color: color,
      title: title,
      child: DropdownButton<T>(
        value: value,
        hint: hint != null
            ? Text(
                "$hint",
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        iconEnabledColor: Theme.of(context).textTheme.bodySmall?.color,
        underline: const SizedBox(),
        alignment: Alignment.centerRight,
        style: Theme.of(context).textTheme.bodySmall,
        onChanged: onChanged,
        selectedItemBuilder: selectedItemBuilder,
        items: items,
      ),
    );
  }
}
