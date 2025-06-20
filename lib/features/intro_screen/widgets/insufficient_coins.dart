import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trivia/core/common_widgets/custom_bottom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/enums/game_mode.dart';
import 'package:trivia/core/utils/size_config.dart';

class InsufficientCoinsWidget extends StatelessWidget {
  final GameMode gameMode;
  final int requiredCoins;
  final int currentCoins;

  const InsufficientCoinsWidget({
    super.key,
    required this.gameMode,
    required this.requiredCoins,
    required this.currentCoins,
  });

  String get _gameModeText {
    switch (gameMode) {
      case GameMode.solo:
        return Strings.soloChallenge;
      case GameMode.duel:
        return Strings.duelChallenge;
      case GameMode.group:
        return Strings.groupChallenge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.lightBlue, Colors.orange],
            ),
          ),
        ),

        Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: EdgeInsets.symmetric(horizontal: calcWidth(40)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _gameModeText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: calcHeight(30)),
                SvgPicture.asset(
                  Strings.emptyChestIcon,
                  height: calcHeight(150),
                ),
                SizedBox(height: calcHeight(20)),
                Text(
                  Strings.insufficientCoins,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
                SizedBox(height: calcHeight(15)),
                Text(
                  '${Strings.youNeed} $requiredCoins ${Strings.coinsToPlayGame}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: calcHeight(10)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: calcWidth(20),
                    vertical: calcHeight(10),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: AppConstant.onPrimaryColor,
                        size: 20,
                      ),
                      SizedBox(width: calcWidth(8)),
                      Text(
                        '${Strings.currentColon} $currentCoins',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: calcHeight(30)),
                Row(
                  spacing: calcWidth(10),
                  children: [
                    Expanded(
                      child: CustomBottomButton(
                        text: Strings.back,
                        onTap: () => pop(),
                        isSecondary: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
