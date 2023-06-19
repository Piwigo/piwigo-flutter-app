import 'package:flutter/material.dart';

class SettingsField extends StatelessWidget {
  const SettingsField({
    Key? key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.padding,
    this.focusNode,
  }) : super(key: key);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? hint;
  final EdgeInsets? padding;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textAlign: TextAlign.start,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}
