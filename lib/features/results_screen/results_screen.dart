import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/app_bar.dart';
import 'package:trivia/features/results_screen/view_model/result_screen_manager.dart';
import 'package:trivia/features/results_screen/widgets/stat_card.dart';

class ResultsScreen extends ConsumerWidget {
  static const routeName = "/results_screen";

  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultState = ref.watch(resultScreenManagerProvider);
    final resultNotifier = ref.read(resultScreenManagerProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: const CustomAppBar(
        title: 'Result',
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35.0),
            topRight: Radius.circular(35.0),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: resultState.when(
            data: (data) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  StatCard(
                    title: 'Correct Answers',
                    value: data.userAchievements.correctAnswers.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  StatCard(
                    title: 'Wrong Answers',
                    value: data.userAchievements.wrongAnswers.toString(),
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 10),
                  StatCard(
                    title: 'Didn\'t Answer',
                    value: data.userAchievements.unanswered.toString(),
                    icon: Icons.help_outline,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  StatCard(
                    title: 'Average Time',
                    value: resultNotifier.getTimeAvg().toStringAsFixed(2),
                    icon: Icons.timer,
                    color: Colors.blue,
                  ),
                ],
              );
            },
            error: (_, __) => const SizedBox(),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
