import 'dart:async';
import 'dart:math';

import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/bots.dart';
import 'package:Quizdom/data/data_source/trivia_room_data_source.dart';
import 'package:Quizdom/data/models/trivia_achievements.dart';
import 'package:Quizdom/data/models/trivia_user.dart';

// Create a separate class for bot-related functionality
class BotManager {
  final Random _random = Random();
  TriviaAchievements _botAchievements = const TriviaAchievements(
    correctAnswers: 0,
    wrongAnswers: 0,
    unanswered: 0,
    sumResponseTime: 0.0,
  );

  // Get current bot achievements
  TriviaAchievements get achievements => _botAchievements;

  // Reset bot achievements
  void resetAchievements() {
    _botAchievements = const TriviaAchievements(
      correctAnswers: 0,
      wrongAnswers: 0,
      unanswered: 0,
      sumResponseTime: 0.0,
    );
  }

  // Update bot achievements based on answer
  void _updateBotAchievements({
    required AchievementField field,
    double? responseTime,
  }) {
    switch (field) {
      case AchievementField.correctAnswers:
        _botAchievements = _botAchievements.copyWith(
          correctAnswers: _botAchievements.correctAnswers + 1,
        );
        break;
      case AchievementField.wrongAnswers:
        _botAchievements = _botAchievements.copyWith(
          wrongAnswers: _botAchievements.wrongAnswers + 1,
        );
        break;
      case AchievementField.unanswered:
        _botAchievements = _botAchievements.copyWith(
          unanswered: _botAchievements.unanswered + 1,
        );
        break;
    }

    _botAchievements = _botAchievements.copyWith(
      sumResponseTime: _botAchievements.sumResponseTime +
          (field != AchievementField.unanswered ? (responseTime ?? 10.0) : 10),
    );
  }

  // Handle bot answers
  Future<void> handleBotAnswer({
    required String roomId,
    required int questionIndex,
    required int correctAnswerIndex,
    required List<String> shuffledOptions,
    required double timeLeft,
  }) async {
    // Calculate a random response time between 1.5 and 6 seconds for the bot
    final botResponseTime = 1 + _random.nextDouble() * 8;

    // Determine if bot gets the answer right (based on accuracy)
    final botGetsItRight =
        _random.nextDouble() < (BotService.currentBot?.accuracy ?? 0.6);

    // Choose the bot's answer
    int botAnswerIndex;
    if (botGetsItRight) {
      // Bot chooses correct answer
      botAnswerIndex = correctAnswerIndex;

      // Update bot achievements for correct answer
      _updateBotAchievements(
        field: AchievementField.correctAnswers,
        responseTime: botResponseTime,
      );
    } else {
      // Bot chooses a random wrong answer
      List<int> wrongIndices = List.generate(shuffledOptions.length, (i) => i)
          .where((i) => i != correctAnswerIndex)
          .toList();

      botAnswerIndex = wrongIndices[_random.nextInt(wrongIndices.length)];

      // Update bot achievements for wrong answer
      _updateBotAchievements(
        field: AchievementField.wrongAnswers,
        responseTime: botResponseTime,
      );
    }

    // Store bot answer in Firestore
    await TriviaRoomDataSource.storeUserAnswer(
        roomId, AppConstant.botUserId, questionIndex, botAnswerIndex);

    if (botGetsItRight) {
      // Calculate the remaining time after bot's response time
      final remainingTime =
          timeLeft > botResponseTime ? timeLeft - botResponseTime : 0.1;

      await TriviaRoomDataSource.updateUserScore(
          roomId, AppConstant.botUserId, questionIndex, remainingTime);
    }
  }

  // Create bot user
  static TriviaUser createBotUser() {
    final botService = BotService();
    final randomBot = botService.createAndSetRandomBot();
    return randomBot.user;
  }

  // Update bot's last seen timestamp
  Future<void> updateBotLastSeen(String roomId) async {
    await TriviaRoomDataSource.updateLastSeen(roomId, AppConstant.botUserId);
  }
}
