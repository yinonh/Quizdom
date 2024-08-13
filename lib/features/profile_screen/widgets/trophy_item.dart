import 'package:flutter/material.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/size_config.dart';

class TrophyItem extends StatelessWidget {
  final String trophyName;
  final Color trophyColor;

  const TrophyItem(
      {required this.trophyName, required this.trophyColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.emoji_events,
          color: trophyColor,
          size: 50,
        ),
        SizedBox(height: calcHeight(8)),
        Text(
          trophyName,
          style: TextStyle(
            fontSize: 16,
            color: AppConstant.primaryColor.toColor(),
          ),
        ),
      ],
    );
  }
}
