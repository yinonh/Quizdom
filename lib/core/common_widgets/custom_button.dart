import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap; // Changed to nullable
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? color;
  final TextStyle? textStyle;
  final List<BoxShadow>? boxShadow;
  final bool isDisabled;
  final IconData? leadingIcon;
  final double? iconSize;
  final double? iconSpacing;
  final bool noGlow; // New parameter for removing glow/shadow

  const CustomButton({
    super.key,
    required this.text,
    this.onTap, // Now nullable
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.textStyle,
    this.boxShadow,
    this.isDisabled = false,
    this.leadingIcon,
    this.iconSize,
    this.iconSpacing,
    this.noGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    // Button is disabled if onTap is null OR isDisabled is true
    bool buttonDisabled = onTap == null || isDisabled;

    return GestureDetector(
      onTap: buttonDisabled ? null : onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.all(8),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 30),
          color: buttonDisabled ? Colors.grey : (color ?? Colors.blue),
          boxShadow: (buttonDisabled || noGlow)
              ? null
              : boxShadow ??
                  [
                    BoxShadow(
                      color: (color ?? Colors.blue).withValues(alpha: 0.5),
                      spreadRadius: 4,
                      blurRadius: 5,
                      offset: const Offset(1, 2),
                    ),
                  ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: iconSize ?? 20.0,
                color: buttonDisabled
                    ? Colors.grey.shade600
                    : (textStyle?.color ?? Colors.white),
              ),
              SizedBox(width: iconSpacing ?? 8.0),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: buttonDisabled
                  ? (textStyle ??
                          const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ))
                      .copyWith(color: Colors.grey.shade600)
                  : textStyle ??
                      const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
