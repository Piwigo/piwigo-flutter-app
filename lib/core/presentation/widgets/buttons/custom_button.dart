import 'package:flutter/material.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/utils/app_text_styles.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onTap,
    required this.text,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final void Function()? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final String text;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingMedium,
            vertical: UIConstants.paddingXSmall,
          ),
          minimumSize: const Size.square(UIConstants.buttonHeight),
          maximumSize: const Size.fromHeight(UIConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
          ),
          backgroundColor: backgroundColor ?? context.theme.colorScheme.secondary,
          foregroundColor: foregroundColor ?? context.theme.colorScheme.primary,
        ),
        child: AnimatedSwitcher(
          duration: UIConstants.animationDurationShort,
          switchInCurve: Curves.ease,
          switchOutCurve: Curves.ease,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Builder(
            key: ValueKey<bool>(isLoading),
            builder: (BuildContext context) {
              if (isLoading) {
                return AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                    color: foregroundColor ?? context.theme.colorScheme.primary,
                  ),
                );
              }
              return Text(
                text,
                style: AppTextStyles.button,
              );
            },
          ),
        ),
      );
}
