import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/app_bar.dart';
import 'package:trivia/features/results_screen/view_model/result_screen_manager.dart';

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
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35.0),
            topRight: Radius.circular(35.0),
          ),
        ),
        child: resultState.when(
          data: (data) {
            return Column(
              children: [
                Text("Correct Answer: ${data.userAchievements.correctAnswers}"),
                Text("Wrong Answer: ${data.userAchievements.wrongAnswers}"),
                Text("Didn't Answer: ${data.userAchievements.unanswered}"),
                Text("TimeAvg: ${resultNotifier.getTimeAvg()}"),
              ],
            );
          },
          error: (_, __) {
            return const SizedBox();
          },
          loading: () {
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
