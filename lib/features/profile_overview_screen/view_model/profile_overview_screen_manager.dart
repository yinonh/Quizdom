import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/data/data_source/user_statistics_data_source.dart';
import 'package:trivia/data/models/user_statistics.dart';

final userStatisticsProvider = FutureProvider.family<UserStatistics?, String>(
  (ref, userId) async {
    try {
      return await UserStatisticsDataSource.getUserStatistics(userId);
    } catch (e) {
      return null;
    }
  },
);
