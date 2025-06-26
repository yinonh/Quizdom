import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/common_widgets/app_bar.dart';
import 'package:Quizdom/core/common_widgets/base_screen.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/categories_screen/categories_screen.dart';
import 'package:Quizdom/features/results_screen/view_model/game_canceled_manager/game_canceled_screen_manager.dart';

class GameCanceledScreen extends ConsumerWidget {
  static const routeName = AppRoutes.gameCancelRouteName;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final opponentLeft = userScores[opponentId] == -1;
    ref.read(gameCanceledScreenManagerProvider(opponentLeft));

    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        appBar: const CustomAppBar(title: Strings.gameCanceled),
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
                      ? Strings.yourOpponentLeftGame
                      : Strings.youLeftGame,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: calcHeight(16)),
                Text(
                  opponentLeft
                      ? Strings.youWinAutomatically
                      : Strings.youLoseAutomatically,
                  style: const TextStyle(fontSize: 18),
                ),
                SizedBox(height: calcHeight(32)),
                ElevatedButton(
                  onPressed: () {
                    goRoute(CategoriesScreen.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: calcWidth(32), vertical: calcHeight(16)),
                  ),
                  child: const Text(Strings.returnHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
