import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_progress_indicator.dart';
import 'package:trivia/core/common_widgets/user_app_bar.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/results_screen/view_model/result_screen_manager.dart';
import 'package:trivia/features/results_screen/widgets/stat_card.dart';
import 'package:trivia/core/constants/constant_strings.dart';

class ResultsScreen extends ConsumerWidget {
  static const routeName = Strings.resultsRouteName;

  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultState = ref.watch(resultScreenManagerProvider);
    final resultNotifier = ref.read(resultScreenManagerProvider.notifier);

    // Listen to the ResultState and call addXpToUser once the state is loaded
    ref.listen<AsyncValue<ResultState>>(
      resultScreenManagerProvider,
      (previous, next) {
        if (next is AsyncData) {
          resultNotifier.addXpToUser(); // This will only add XP once
        }
      },
    );

    return Scaffold(
      appBar: UserAppBar(
        prefix: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: resultState.when(
          data: (data) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: calcHeight(20)),
                StatCard(
                  title: Strings.correctAnswers,
                  value: data.userAchievements.correctAnswers.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                SizedBox(height: calcHeight(10)),
                StatCard(
                  title: Strings.wrongAnswers,
                  value: data.userAchievements.wrongAnswers.toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
                SizedBox(height: calcHeight(10)),
                StatCard(
                  title: Strings.didntAnswer,
                  value: data.userAchievements.unanswered.toString(),
                  icon: Icons.help_outline,
                  color: Colors.grey,
                ),
                SizedBox(height: calcHeight(10)),
                StatCard(
                  title: Strings.averageTime,
                  value: resultNotifier.getTimeAvg().toStringAsFixed(2),
                  icon: Icons.timer,
                  color: Colors.blue,
                ),
              ],
            );
          },
          error: (_, __) => const SizedBox(),
          loading: () => const Center(child: CustomProgressIndicator()),
        ),
      ),
    );
  }
}
