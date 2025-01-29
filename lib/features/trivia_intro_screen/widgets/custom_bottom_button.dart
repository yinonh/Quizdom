import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';

class CustomBottomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSecondary;

  const CustomBottomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSecondary
              ? AppConstant.secondaryColor.withValues(alpha: 0.5)
              : AppConstant.primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSecondary ? FontWeight.normal : FontWeight.bold,
            color: isSecondary ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
