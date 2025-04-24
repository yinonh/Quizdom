import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData prefixIcon;
  final Widget suffixIcon;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.prefixIcon,
    required this.onChanged,
    this.suffixIcon = const SizedBox.shrink(),
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppConstant.white),
        prefixIcon: Icon(prefixIcon, color: AppConstant.white),
        suffixIcon: suffixIcon,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppConstant.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppConstant.white),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppConstant.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppConstant.red),
        ),
        errorText: errorText,
      ),
      style: const TextStyle(color: AppConstant.white),
      obscureText: obscureText,
    );
  }
}
