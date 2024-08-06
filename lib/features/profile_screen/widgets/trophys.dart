import 'package:flutter/material.dart';

class TrophySection extends StatelessWidget {
  const TrophySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trophies',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00afff),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TrophyItem(trophyName: 'Gold', trophyColor: Color(0xFFFFD700)),
            TrophyItem(trophyName: 'Silver', trophyColor: Color(0xFFC0C0C0)),
            TrophyItem(trophyName: 'Bronze', trophyColor: Color(0xFFCD7F32)),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TrophyItem(trophyName: 'Platinum', trophyColor: Color(0xFFE5E4E2)),
            TrophyItem(trophyName: 'Diamond', trophyColor: Color(0xFFB9F2FF)),
            TrophyItem(trophyName: 'Ruby', trophyColor: Color(0xFFE0115F)),
          ],
        ),
      ],
    );
  }
}

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
