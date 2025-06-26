import 'package:flutter/material.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class CustomBottomButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final bool isSecondary;
  final Color? backgroundColor;

  const CustomBottomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isSecondary = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: onTap == null
            ? Colors.grey
            : backgroundColor ??
                (isSecondary
                    ? AppConstant.secondaryColor.withValues(alpha: 0.5)
                    : AppConstant.primaryColor),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: calcWidth(24),
          vertical: calcHeight(15),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black
            .withValues(alpha: onTap == null ? 0.0 : 0.3), // Shadow color
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: onTap == null
              ? Colors.white60 // Lighter text color when disabled
              : (isSecondary ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}
