import 'package:flutter/material.dart';

class AppField extends StatefulWidget {
  const AppField({
    Key? key,
    this.icon,
    this.prefix,
    this.suffix,
    this.clearAction,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.hint,
    this.padding,
    this.margin,
    this.obscureText = false,
    this.enableClearAction = false,
    this.error = false,
    this.color,
    this.onFieldSubmitted,
    this.onChanged,
    this.keyboardType,
  }) : super(key: key);

  final Widget? icon;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? clearAction;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? hint;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool obscureText;
  final bool enableClearAction;
  final bool error;
  final Color? color;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
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
    if (widget.enableClearAction) {
      setState(() {
        _value = value;
      });
    }
  }

  void _onClearField() {
    if (widget.controller != null) {
      setState(() {
        widget.controller!.clear();
        _value = '';
      });
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.icon != null) _buildIcon(),
          if (widget.prefix != null) widget.prefix!,
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: _onChangedField,
              onFieldSubmitted: widget.onFieldSubmitted,
              textInputAction: widget.textInputAction,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hint,
                isDense: true,
              ),
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
          if (_value.isNotEmpty && widget.enableClearAction) _buildClearAction(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Theme(
      data: ThemeData(
        iconTheme: IconThemeData(
          color: Theme.of(context).inputDecorationTheme.prefixIconColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: widget.icon!,
      ),
    );
  }

  Widget _buildClearAction() {
    return Builder(builder: (context) {
      if (widget.clearAction != null) {
        return widget.clearAction!;
      }
      return GestureDetector(
        onTap: _onClearField,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.clear,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      );
    });
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
