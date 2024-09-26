import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/app_bar.dart';
import 'package:trivia/features/quiz_screen/view_model/quiz_screen_manager.dart';
import 'package:trivia/features/quiz_screen/widgets/question_widget.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';

class QuizScreen extends ConsumerWidget {
  static const routeName = Strings.quizRouteName;
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(quizScreenManagerProvider);
    return Scaffold(
      backgroundColor: AppConstant.primaryColor,
      appBar: CustomAppBar(
        title:
            '${Strings.question} ${(questionsState.asData?.value.questionIndex ?? 0) + 1}',
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
        child: QuestionWidget(),
      ),
    );
  }
}
