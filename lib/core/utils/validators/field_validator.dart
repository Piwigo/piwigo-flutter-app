import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/utils/app_regexp.dart';

abstract class FieldValidator {
  String? validate(BuildContext context, String? value);
}

class RequiredValidator extends FieldValidator {
  @override
  String? validate(BuildContext context, String? value) {
    if (value != null && value.isNotEmpty) {
      return null;
    }
    return 'This field is required'; // todo: localization
  }
}

class UrlValidator extends FieldValidator {
  @override
  String? validate(BuildContext context, String? value) {
    RegExp urlCheck = AppRegexp.urlCheck;
    if (value != null && urlCheck.hasMatch(value)) {
      return null;
    }
    return context.localizations.serverURLerror_message;
  }
}
