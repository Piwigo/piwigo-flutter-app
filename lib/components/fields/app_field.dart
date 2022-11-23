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
  }) : super(key: key);

  final Widget? prefix;
  final Widget? suffix;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? hint;
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
        //border: error ? Border.all(color: Theme.of(context).errorColor, width: 1) : null,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          contentPadding: padding ?? const EdgeInsets.all(16.0),
          hintText: hint,
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
              color: Theme.of(context).errorColor,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).errorColor,
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

class AppDescriptionField extends StatefulWidget {
  const AppDescriptionField({
    Key? key,
    this.controller,
    this.minLines,
    this.maxLines,
    this.focusNode,
    this.textInputAction,
    this.keyboardType,
    this.hint,
    this.padding,
    this.margin,
    this.error = false,
    this.color,
    this.onFieldSubmitted,
    this.onChanged,
  }) : super(key: key);

  final TextEditingController? controller;
  final int? minLines;
  final int? maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? hint;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool error;
  final Color? color;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;

  @override
  State<AppDescriptionField> createState() => _AppDescriptionFieldState();
}

class _AppDescriptionFieldState extends State<AppDescriptionField> {
  String _value = '';

  @override
  void initState() {
    if (widget.controller != null) {
      _value = widget.controller!.text;
    }
    super.initState();
  }

  void _onChangedField(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null) {
      _value = widget.controller!.text;
    }
    EdgeInsets errorPadding = (widget.error ? const EdgeInsets.all(0) : const EdgeInsets.all(1));
    return Container(
      margin: widget.margin,
      padding: (widget.padding ?? const EdgeInsets.all(0)) + errorPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: widget.color ?? Theme.of(context).inputDecorationTheme.fillColor,
        border: widget.error ? Border.all(color: Theme.of(context).errorColor, width: 1) : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        onChanged: _onChangedField,
        onFieldSubmitted: widget.onFieldSubmitted,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hint,
          isDense: true,
        ),
      ),
    );
  }
}
