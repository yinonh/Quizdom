import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/service/current_trivia_achievements_provider.dart';
import 'package:trivia/data/service/trivia_provider.dart';
import 'package:trivia/data/service/general_trivia_room_provider.dart';
import 'package:trivia/data/service/user_provider.dart';
import 'package:trivia/data/service/user_statistics_provider.dart';

part 'categories_screen_manager.freezed.dart';

part 'categories_screen_manager.g.dart';

@freezed
class CategoriesState with _$CategoriesState {
  const factory CategoriesState({
    required List<GeneralTriviaRoom>? triviaRooms,
    required List<int> userRecentCategories,
    required bool showRowLogin,
    required int daysInRow,
  }) = _CategoriesState;
}

@riverpod
class CategoriesScreenManager extends _$CategoriesScreenManager {
  Trivia? _triviaProviderNotifier;
  Auth? _userProviderNotifier;

  Trivia? get triviaProviderNotifier {
    return _triviaProviderNotifier ??= ref.read(triviaProvider.notifier);
  }

  Auth? get userProviderNotifier {
    return _userProviderNotifier ??= ref.read(authProvider.notifier);
  }

  @override
  Future<CategoriesState> build() async {
    // Fetch necessary data
    final user = ref.watch(authProvider);
    final userStatistics = ref.read(statisticsProvider).userStatistics;
    return CategoriesState(
      triviaRooms: ref.read(generalTriviaRoomsProvider).generalTriviaRooms,
      userRecentCategories: user.currentUser.recentTriviaCategories,
      showRowLogin: user.loginNewDayInARow ?? false,
      daysInRow: userStatistics.currentLoginStreak,
    );
  }

  void onClaim(int award) {
    ref.read(authProvider.notifier).onClaim(award);
  }

  void setTriviaRoom(String triviaRoomId) {
    ref.read(generalTriviaRoomsProvider.notifier).selectRoom(triviaRoomId);
    ref.read(currentTriviaAchievementsProvider.notifier).resetAchievements();
    userProviderNotifier?.addTriviaCategory(
        ref.read(generalTriviaRoomsProvider).selectedRoom?.categoryId ?? -1);
  }

  // Function to clean up category names
  String cleanCategoryName(String name) {
    return name.replaceAll(RegExp(r'^(Entertainment: |Science: )'), '').trim();
  }
}
