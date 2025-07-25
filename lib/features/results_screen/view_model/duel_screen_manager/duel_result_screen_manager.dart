import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/bots.dart';
import 'package:Quizdom/core/utils/enums/game_stage.dart';
import 'package:Quizdom/core/utils/general_functions.dart';
import 'package:Quizdom/data/data_source/trivia_room_data_source.dart';
import 'package:Quizdom/data/data_source/user_data_source.dart';
import 'package:Quizdom/data/models/trivia_achievements.dart';
import 'package:Quizdom/data/models/trivia_room.dart';
import 'package:Quizdom/data/models/trivia_user.dart';
import 'package:Quizdom/data/providers/user_provider.dart';
import 'package:Quizdom/data/providers/user_statistics_provider.dart';

part 'duel_result_screen_manager.freezed.dart';
part 'duel_result_screen_manager.g.dart';

@freezed
class DuelResultState with _$DuelResultState {
  const factory DuelResultState({
    required TriviaRoom room,
    required String currentUserId,
    required TriviaUser? currentUser,
    required TriviaUser? opponentUser,
    required String? winnerId,
  }) = _DuelResultState;
}

@riverpod
class DuelResultScreenManager extends _$DuelResultScreenManager {
  @override
  Future<DuelResultState> build(String roomId) async {
    try {
      // Get room data
      final room = await TriviaRoomDataSource.getRoomById(roomId);
      if (room == null || room.currentStage != GameStage.completed) {
        throw Exception('Room not found or game not completed');
      }

      // Get current user ID
      final currentUserId = ref.read(authProvider).currentUser.uid;

      // Get opponent ID
      final opponentId = room.users.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      // Get user profiles
      final currentUser = await UserDataSource.getUserById(currentUserId);
      TriviaUser? opponentUser;
      if (opponentId == AppConstant.botUserId) {
        opponentUser = BotService.currentBot?.user;
      } else {
        opponentUser = opponentId.isNotEmpty
            ? await UserDataSource.getUserById(opponentId)
            : null;
      }

      // Determine winner
      String? winnerId;
      if (room.users.length >= 2 && (room.userScores?.length ?? 0) >= 2) {
        // Check if there's a winner
        if (room.userScores?[room.users[0]] !=
            room.userScores?[room.users[1]]) {
          winnerId = room.userScores![room.users[0]]! >
                  room.userScores![room.users[1]]!
              ? room.users[0]
              : room.users[1];
        }
      }

      // Update statistics for current user
      final currentUserAchievements = room.userAchievements?[currentUserId];
      if (currentUserAchievements != null) {
        final avgResponseTime = currentUserAchievements.sumResponseTime /
            (currentUserAchievements.correctAnswers +
                currentUserAchievements.wrongAnswers +
                currentUserAchievements.unanswered);

        await ref.read(statisticsProvider.notifier).updateUserStatistics(
              addToTotalGamesPlayed: 1,
              addToGamesAgainstPlayers: 1,
              addToCorrectAnswers: currentUserAchievements.correctAnswers,
              addToWrongAnswers: currentUserAchievements.wrongAnswers,
              addToUnanswered: currentUserAchievements.unanswered,
              sessionAvgAnswerTime: avgResponseTime,
              addToScore: calculateTotalScore(currentUserAchievements),
              wonGame: winnerId == currentUserId,
            );
      }

      return DuelResultState(
        room: room,
        currentUserId: currentUserId,
        currentUser: currentUser,
        opponentUser: opponentUser,
        winnerId: winnerId,
      );
    } catch (e) {
      throw Exception('Failed to load duel results: $e');
    }
  }

  // Helper method to calculate average response time
  double calculateAverageResponseTime(TriviaAchievements achievements) {
    final answeredQuestions =
        achievements.correctAnswers + achievements.wrongAnswers;
    if (answeredQuestions == 0) return AppConstant.questionTime.toDouble();
    return achievements.sumResponseTime / answeredQuestions;
  }

  // Helper method to calculate accuracy
  double calculateAccuracy(TriviaAchievements achievements) {
    final totalAttempted =
        achievements.correctAnswers + achievements.wrongAnswers;
    if (totalAttempted == 0) return 0;
    return achievements.correctAnswers / totalAttempted * 100;
  }
}
