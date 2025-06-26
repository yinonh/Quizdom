import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/data/models/trivia_user.dart';
import 'package:Quizdom/data/providers/user_provider.dart';

part 'wheel_screen_manager.freezed.dart';
part 'wheel_screen_manager.g.dart';

@freezed
class WheelState with _$WheelState {
  const factory WheelState({
    required TriviaUser currentUser,
  }) = _WheelState;
}

@riverpod
class WheelScreenManager extends _$WheelScreenManager {
  @override
  WheelState build() {
    final currentUser = ref.watch(authProvider).currentUser;

    return WheelState(
      currentUser: currentUser,
    );
  }

  Future<void> updateCoins(int amount) async {
    ref.read(authProvider.notifier).updateCoins(amount);
  }
}
