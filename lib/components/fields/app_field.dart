import 'package:flutter/material.dart';

class AppField extends StatelessWidget {
  const AppField({
    Key? key,
    this.prefix,
    this.suffix,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.hint,
    this.padding,
    this.margin,
    this.obscureText = false,
    this.error = false,
    this.color,
    this.onFieldSubmitted,
    this.onChanged,
    this.keyboardType,
    this.minLines,
    this.maxLines = 1,
    this.label,
  }) : super(key: key);

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
  final EdgeInsets? margin;
  final bool obscureText;
  final bool error;
  final Color? color;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: color ?? Theme.of(context).inputDecorationTheme.fillColor,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        obscureText: obscureText,
        minLines: minLines,
        maxLines: maxLines,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          contentPadding: padding ?? const EdgeInsets.all(16.0),
          hintText: hint,
          labelText: label,
          alignLabelWithHint: true,
          isDense: true,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32.0,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 32.0,
          ),
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 0.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1.0,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 2.0,
            ),
          ),
          errorText: error == true ? '' : null,
          errorStyle: TextStyle(height: 0.0),
        ),
      ),
    );
  }
}
