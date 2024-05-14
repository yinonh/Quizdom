import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trivia/commom_widgets/app_bar.dart';
import 'package:trivia/data/trivia_provider.dart';
import 'package:trivia/features/question_screen/view_model/quiz_screen_manager.dart';

class QuestionScreen extends ConsumerWidget {
  static const routName = "/question_screen";
  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(quizScreenManagerProvider);
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Question',
      ),
      body: questionsState.when(data: (data) {
        return Text(data.triviaResponse.results![0].question!);
      }, error: (error, _) {
        return Text(error.toString());
      }, loading: () {
        return const CircularProgressIndicator();
      }),
    );
  }
}
