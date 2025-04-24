import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';

class WaitingOrCountdown extends StatelessWidget {
  const WaitingOrCountdown({super.key});

  static const animationDuration = Duration(seconds: 5);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: calcHeight(20),
        children: [
          FutureBuilder(
            future: Future.delayed(animationDuration),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  padding: EdgeInsets.all(calcWidth(10)),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstant.primaryColor,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  height: calcHeight(250),
                  width: calcWidth(250),
                  child: Lottie.asset(
                    Strings.countDownAnimation,
                    repeat: false,
                  ),
                );
              }
            },
          ),
          const Text(
            Strings.waitingPlayersJoin,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
