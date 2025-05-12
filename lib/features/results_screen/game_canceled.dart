import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/common_widgets/app_bar.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';

class GameCanceledScreen extends StatelessWidget {
  static const routeName = 'game-canceled';

  final List users;
  final Map<String, int> userScores;
  final String currentUserId;
  final String opponentId;

  const GameCanceledScreen({
    super.key,
    required this.users,
    required this.userScores,
    required this.currentUserId,
    required this.opponentId,
  });

  @override
  Widget build(BuildContext context) {
    final opponentLeft = userScores[opponentId] == -1;

    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        appBar: const CustomAppBar(title: 'Game Canceled'),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: calcWidth(20)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  opponentLeft
                      ? Icons.emoji_events
                      : Icons.sentiment_dissatisfied,
                  size: 80,
                  color: opponentLeft ? Colors.amber : Colors.grey,
                ),
                const SizedBox(height: 24),
                Text(
                  opponentLeft
                      ? 'Your opponent left the game'
                      : 'You left the game',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  opponentLeft
                      ? 'You win automatically!'
                      : 'You lose automatically.',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    context.goNamed(CategoriesScreen.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
