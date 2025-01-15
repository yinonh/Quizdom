import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/profile_screen/widgets/trophy_item.dart';

class TrophiesSection extends StatelessWidget {
  const TrophiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(35.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  Strings.trophies,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstant.primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstant.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppConstant.primaryColor,
                  size: 28,
                ),
              ),
            ],
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
        ],
      ),
    );
  }
}
