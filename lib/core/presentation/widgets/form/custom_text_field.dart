import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';
import 'package:piwigo_ng/core/utils/validators/field_validator.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.textInputAction,
    this.keyboardType,
    this.hint,
    this.label,
    this.minLines,
    this.maxLines = 1,
    this.padding,
    this.obscureText = false,
    this.canErase = false,
    this.color,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofillHints,
    this.validators = const <FieldValidator>[],
  });

  final Widget? prefix;
  final Widget? suffix;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? hint;
  final String? label;
  final int? minLines;
  final int? maxLines;
  final EdgeInsets? padding;
  final bool obscureText;
  final bool canErase;
  final Color? color;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final Iterable<String>? autofillHints;
  final List<FieldValidator> validators;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    widget.controller?.addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_listener);
    super.dispose();
  }

  void _listener() => setState(() {});

  EdgeInsets get _contentPadding =>
      widget.padding ??
      const EdgeInsets.symmetric(
        vertical: UIConstants.paddingMedium,
        horizontal: UIConstants.paddingXSmall,
      );

  String? _validator(String? value) {
    for (FieldValidator validator in widget.validators) {
      String? error = validator.validate(context, value);
      if (error != null) return error;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        autofillHints: widget.autofillHints,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          contentPadding: _contentPadding,
          hintText: widget.hint,
          labelText: widget.label,
          alignLabelWithHint: true,
          isDense: true,
          prefixIconConstraints: const BoxConstraints(),
          suffixIconConstraints: const BoxConstraints(),
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: UIConstants.paddingSmall,
              right: _contentPadding.left,
            ),
            child: widget.prefix,
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.only(
              right: UIConstants.paddingSmall,
              left: _contentPadding.right,
            ),
            child: AnimatedSize(
              duration: UIConstants.animationDurationShort,
              curve: Curves.ease,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.canErase && (widget.controller?.text.isNotEmpty ?? false)) _buildClearTextButton(),
                  if (widget.suffix != null) ...<Widget>[
                    const SizedBox(width: UIConstants.paddingXSmall),
                    widget.suffix!,
                  ],
                ],
              ),
            ),
          ),
          fillColor: widget.color ?? Theme.of(context).inputDecorationTheme.fillColor,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: UIConstants.thicknessMedium,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: UIConstants.thicknessMedium,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          errorStyle: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: context.theme.colorScheme.error,
          ),
        ),
        validator: _validator,
      );

  Widget _buildClearTextButton() => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.controller?.clear(),
        child: Icon(
          Icons.clear,
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
}
