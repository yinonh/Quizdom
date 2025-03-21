import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/app_bar.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/features/quiz_screen/view_model/duel_quiz_screen_manager.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_question_widget.dart';

class DuelQuizScreen extends ConsumerWidget {
  static const routeName = Strings.duelQuizRouteName;

  const DuelQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(duelQuizScreenManagerProvider);
    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        appBar: CustomAppBar(
          title: questionsState.when(
            data: (state) => cleanCategoryName(state.categoryName),
            error: (error, _) {
              return "";
            },
            loading: () {
              return "";
            },
          ),
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
          child: DuelQuestionWidget(),
        ),
      ),
    );
  }
}
