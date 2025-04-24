import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/size_config.dart';

class InfoContainer extends StatelessWidget {
  final String text;

  const InfoContainer({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: calcHeight(100),
        color: AppConstant.lightGray,
        child: Center(child: Text(text)),
      ),
    );
  }
}
