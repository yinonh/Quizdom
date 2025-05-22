import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/constants/bots.dart';
import 'package:trivia/data/data_source/user_statistics_data_source.dart';
import 'package:trivia/data/models/user_statistics.dart';

part 'profile_overview_screen_manager.g.dart';

@riverpod
Future<UserStatistics?> userStatistics(Ref ref, String userId) async {
  try {
    UserStatistics? statistics =
        await UserStatisticsDataSource.getUserStatistics(userId);
    statistics ??= BotService.currentBot?.statistics;
    return statistics;
  } catch (e) {
    return null;
  }
}
