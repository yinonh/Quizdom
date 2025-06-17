import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
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

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.textStyle,
    this.boxShadow,
    this.isDisabled = false, // Default to false if not provided
    this.leadingIcon,
    this.iconSize,
    this.iconSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap, // Disable tap when `isDisabled` is true
      child: Container(
        margin: margin ?? const EdgeInsets.all(8),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 30),
          color: isDisabled
              ? Colors.grey
              : (color ?? Colors.blue), // Gray when disabled
          boxShadow: isDisabled
              ? [] // No shadow when disabled
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
                color: isDisabled
                    ? Colors.grey.shade600
                    : (textStyle?.color ?? Colors.white),
              ),
              SizedBox(width: iconSpacing ?? 8.0),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: textStyle ??
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
