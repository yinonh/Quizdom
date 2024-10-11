import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';

class EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? errorText;

  const EditableField({
    required this.label,
    required this.controller,
    this.errorText,
    this.isPassword = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          errorStyle: TextStyle(color: Colors.red),
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: AppConstant.highlightColor,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: AppConstant.highlightColor,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: AppConstant.highlightColor,
            ),
          ),
        ),
      ),
    );
  }
}
