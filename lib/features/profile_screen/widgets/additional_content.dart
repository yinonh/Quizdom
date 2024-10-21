import 'package:flutter/material.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/profile_screen/widgets/trophy_item.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';

class AdditionalContent extends StatelessWidget {
  const AdditionalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(35.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            Strings.trophies,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstant.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TrophyItem(
                trophyName: Strings.goldTrophy,
                trophyColor: AppConstant.goldColor,
              ),
              TrophyItem(
                trophyName: Strings.silverTrophy,
                trophyColor: AppConstant.silverColor,
              ),
              TrophyItem(
                trophyName: Strings.bronzeTrophy,
                trophyColor: AppConstant.bronzeColor,
              ),
            ],
          ),
          SizedBox(height: calcHeight(15)),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TrophyItem(
                trophyName: Strings.platinumTrophy,
                trophyColor: AppConstant.platinumColor,
              ),
              TrophyItem(
                trophyName: Strings.diamondTrophy,
                trophyColor: AppConstant.diamondColor,
              ),
              TrophyItem(
                trophyName: Strings.rubyTrophy,
                trophyColor: AppConstant.rubyColor,
              ),
            ],
          ),
          SizedBox(height: calcHeight(15)),
          const Text(
            Strings.statisticsTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstant.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text("${Strings.correctAnswersText}10"),
          const Text("${Strings.bestTimeText}10"),
          const Text("${Strings.bestTotalScoreText}10"),
        ],
      ),
    );
  }
}
