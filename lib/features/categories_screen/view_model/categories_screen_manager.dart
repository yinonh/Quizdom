import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/enums/game_mode.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/providers/current_trivia_achievements_provider.dart';
import 'package:trivia/data/providers/game_mode_provider.dart';
import 'package:trivia/data/providers/general_trivia_room_provider.dart';
import 'package:trivia/data/providers/solo_trivia_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/data/providers/user_statistics_provider.dart';

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
  SoloTrivia? _triviaProviderNotifier;
  Auth? _userProviderNotifier;

  SoloTrivia? get triviaProviderNotifier {
    return _triviaProviderNotifier ??= ref.read(soloTriviaProvider.notifier);
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

  void setGeneralTriviaRoom(String triviaRoomId) {
    ref.read(generalTriviaRoomsProvider.notifier).selectRoom(triviaRoomId);
    ref.read(currentTriviaAchievementsProvider.notifier).resetAchievements();
    ref.read(gameModeNotifierProvider.notifier).setMode(GameMode.solo);
    userProviderNotifier?.addTriviaCategory(
        ref.read(generalTriviaRoomsProvider).selectedRoom?.categoryId ?? -1);
  }

  void setTriviaRoom() {
    ref.read(gameModeNotifierProvider.notifier).setMode(GameMode.duel);
    // Listen to the stream and print rooms
    // TriviaRoomDataSource.watchAvailableRooms().listen(
    //   (rooms) {
    //     print('Available Rooms:');
    //     for (var room in rooms) {
    //       print('Room ID: ${room.roomId}');
    //       print('Users: ${room.users}');
    //       print('-------------------');
    //     }
    //   },
    //   onError: (error) {
    //     print('Error watching rooms: $error');
    //   },
    // );
    ref.read(currentTriviaAchievementsProvider.notifier).resetAchievements();
  }

  void setGroupTriviaRoom() {
    ref.read(gameModeNotifierProvider.notifier).setMode(GameMode.group);
    ref.read(currentTriviaAchievementsProvider.notifier).resetAchievements();
  }
}
