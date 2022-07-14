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


class TextFieldSearch extends StatefulWidget {
  const TextFieldSearch({Key key, this.controller, this.hint, this.padding, this.margin, this.onSubmit, this.onTap, this.focusNode,}) : super(key: key);

  final TextEditingController controller;
  final String hint;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Function(String) onSubmit;
  final Function() onTap;
  final FocusNode focusNode;

  @override
  State<TextFieldSearch> createState() => _TextFieldSearchState();
}

class _TextFieldSearchState extends State<TextFieldSearch> {
  final FocusNode _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    var _theme = Theme.of(context);

    return Container(
      margin: widget.margin ?? EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 5, vertical: 0),
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
              controller: widget.controller,
              focusNode: _focus,
              onTap: widget.onTap,
              onFieldSubmitted: widget.onSubmit,
              onChanged: (string) {
                setState(() {});
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hint,
              ),
            ),
          ),
          if(widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                _focus.unfocus();
                if(widget.onSubmit != null) {
                  widget.onSubmit(widget.controller.text);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.close, color: _theme.iconTheme.color),
              ),
            ),
        ],
      ),
    );
  }
}