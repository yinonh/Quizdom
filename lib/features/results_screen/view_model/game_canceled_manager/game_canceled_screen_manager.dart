import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/data/providers/user_statistics_provider.dart';

part 'game_canceled_screen_manager.g.dart';

@riverpod
class GameCanceledScreenManager extends _$GameCanceledScreenManager {
  @override
  Future<void> build(bool won) async {
    try {
      await ref.read(statisticsProvider.notifier).updateUserStatistics(
            addToTotalGamesPlayed: 1,
            addToGamesAgainstPlayers: 1,
            addToScore: won ? 10 : 0,
            wonGame: won,
          );
    } catch (e) {
      throw Exception('Failed to load duel results: $e');
    }
  }
}
