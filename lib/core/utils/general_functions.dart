import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/data/models/trivia_achievements.dart';
import 'package:Quizdom/data/models/trivia_user.dart';
import 'package:Quizdom/features/profile_overview_screen/profile_overview_screen.dart';

Map<String, dynamic> decodeFields(Map<String, dynamic> result) {
  return {
    'difficulty': utf8.decode(base64.decode(result['difficulty'])),
    'category': utf8.decode(base64.decode(result['category'])),
    'question': utf8.decode(base64.decode(result['question'])),
    'correct_answer': utf8.decode(base64.decode(result['correct_answer'])),
    'incorrect_answers': (result['incorrect_answers'] as List).map((answer) {
      return utf8.decode(base64.decode(answer));
    }).toList(),
  };
}

String formatNumber(int number) {
  if (number >= 1000000) {
    double result = number / 1000000;
    return '${result.toStringAsFixed(2)}M';
  } else if (number >= 1000) {
    double result = number / 1000;
    return '${result.toStringAsFixed(2)}K';
  }
  return number.toString();
}

// Function to clean up category names
String cleanCategoryName(String name) {
  return name.replaceAll(RegExp(r'^(Entertainment: |Science: )'), '').trim();
}

void showProfileOverview(BuildContext context, TriviaUser user) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return ProfileBottomSheet(
        user: user,
      );
    },
  );
}

double getTimeAvg(TriviaAchievements achievements) {
  final totalQuestions = achievements.correctAnswers +
      achievements.wrongAnswers +
      achievements.unanswered;

  if (totalQuestions == 0) return 0.0;

  return AppConstant.questionTime -
      (achievements.sumResponseTime / totalQuestions);
}

int calculateTotalScore(TriviaAchievements achievements) {
  // Define weights
  const int maxScore = 100;
  const double correctWeight = 0.7; // 70% weight for correct answers
  const double timeWeight = 0.3; // 30% weight for response time efficiency

  // Calculate the total number of questions
  final int totalQuestions = achievements.correctAnswers +
      achievements.wrongAnswers +
      achievements.unanswered;

  if (totalQuestions == 0) return 0;

  // Normalize the correct answers
  final double correctFactor = achievements.correctAnswers / totalQuestions;

  // Normalize the time factor (0 if max time exceeded, 1 if perfect)
  final double maxTimePerQuestion = AppConstant.questionTime.toDouble();

  final double timeFactor =
      (getTimeAvg(achievements) / maxTimePerQuestion).clamp(0.0, 1.0);

  // Calculate weighted score
  final double rawScore =
      (correctFactor * correctWeight) + (timeFactor * timeWeight);

  // Map rawScore to 0–100 range and return as an int
  return (rawScore.clamp(0.0, 1.0) * maxScore).round();
}

String generateGuestName(String userId) {
// Take first 6 characters of userId and make it readable
  final suffix = userId.substring(0, 5).toUpperCase();
  return '${Strings.guest} $suffix';
}
