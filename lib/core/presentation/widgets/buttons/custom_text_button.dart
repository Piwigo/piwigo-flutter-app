import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/utils/app_text_styles.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    this.onTap,
    required this.text,
    this.foregroundColor,
  });

  final void Function()? onTap;
  final Color? foregroundColor;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? context.theme.colorScheme.secondary,
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingXSmall,
              vertical: UIConstants.paddingTiny,
            ),
            minimumSize: Size.zero,
          ),
          onPressed: onTap,
          child: Text(
            text,
            style: AppTextStyles.textButton,
          ),
        ),
      );
}
