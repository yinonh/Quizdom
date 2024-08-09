import 'package:flutter/material.dart';

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
        const SizedBox(height: 8),
        Text(
          trophyName,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF00afff),
          ),
        ),
      ],
    );
  }
}
