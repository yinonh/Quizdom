import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/service/trivia_provider.dart';
import 'package:trivia/data/service/trivia_room_provider.dart';
import 'package:trivia/data/service/user_provider.dart';

part 'categories_screen_manager.freezed.dart';

part 'categories_screen_manager.g.dart';

@freezed
class CategoriesState with _$CategoriesState {
  const factory CategoriesState({
    required List<GeneralTriviaRoom>? triviaRooms,
    required List<int> userRecentCategories,
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
    return CategoriesState(
      triviaRooms: ref.read(triviaRoomsProvider).generalTriviaRooms,
      userRecentCategories: user.currentUser.recentTriviaCategories,
    );
  }

  // Reset achievements using the initialized notifier
  void resetAchievements() {
    userProviderNotifier?.resetAchievements();
  }

  void setTriviaRoom(String triviaRoomId) {
    ref.read(triviaRoomsProvider.notifier).selectRoom(triviaRoomId);
    userProviderNotifier?.addTriviaCategory(
        ref.read(triviaRoomsProvider).selectedRoom?.categoryId ?? -1);
  }

  // Function to clean up category names
  String cleanCategoryName(String name) {
    return name.replaceAll(RegExp(r'^(Entertainment: |Science: )'), '').trim();
  }
}
