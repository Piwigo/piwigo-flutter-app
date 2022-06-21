import 'package:flutter/material.dart';


class TextFieldRequired extends StatelessWidget {
  const TextFieldRequired({Key key, this.controller, this.validator, this.hint = ""}) : super(key: key);

  final TextEditingController controller;
  final Function(String) validator;
  final String hint;

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);

    controller ?? TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _theme.inputDecorationTheme.fillColor
      ),
      child: TextFormField(
        maxLines: 1,
        controller: controller,
        style: _theme.inputDecorationTheme.labelStyle,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: _theme.inputDecorationTheme.hintStyle,
        ),
        validator: validator,
      ),
    );
  }
}

class TextFieldDescription extends StatelessWidget {
  const TextFieldDescription({Key key, this.controller, this.hint, this.minLines = 1, this.maxLines = 3, this.padding}) : super(key: key);

  final TextEditingController controller;
  final String hint;
  final int minLines;
  final int maxLines;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _theme.inputDecorationTheme.fillColor
      ),
      child: TextFormField(
        minLines: minLines,
        maxLines: maxLines,
        controller: controller,
        style: _theme.inputDecorationTheme.labelStyle,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: _theme.inputDecorationTheme.hintStyle,
        ),
      ),
    );
  }
}


class TextFieldSearch extends StatelessWidget {
  const TextFieldSearch({Key key, this.controller, this.hint, this.padding, this.margin}) : super(key: key);

  final TextEditingController controller;
  final String hint;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _theme.inputDecorationTheme.fillColor,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.search, color: _theme.iconTheme.color),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}