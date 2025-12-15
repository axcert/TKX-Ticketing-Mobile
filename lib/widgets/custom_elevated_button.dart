import 'package:flutter/material.dart';
import 'package:tkx_ticketing/config/app_theme.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? elevation;
  final Widget? icon;
  final bool enabled;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon!,
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 15,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  color: textColor ?? Colors.white,
                ),
              ),
            ],
          )
        : Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 15,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          );

    final button = ElevatedButton(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: AppColors.primaryLight,
        disabledForegroundColor: AppColors.primaryLight,
        padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        elevation: elevation ?? 0,
      ),
      child: buttonChild,
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
