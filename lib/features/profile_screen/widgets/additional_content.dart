import 'package:flutter/material.dart';
import 'package:trivia/features/profile_screen/widgets/trophy_item.dart';

class AdditionalContent extends StatelessWidget {
  const AdditionalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35.0),
          topRight: Radius.circular(35.0),
        ),
      ),
      child: const Column(
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
              TrophyItem(
                  trophyName: 'Platinum', trophyColor: Color(0xFFE5E4E2)),
              TrophyItem(trophyName: 'Diamond', trophyColor: Color(0xFFB9F2FF)),
              TrophyItem(trophyName: 'Ruby', trophyColor: Color(0xFFE0115F)),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00afff),
            ),
          ),
          SizedBox(height: 16),
          Text("Correct answers in round: 10"),
          Text("Best time: 10"),
          Text("Best total score: 10"),
        ],
      ),
    );
  }
}
