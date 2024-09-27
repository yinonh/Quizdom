import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/service/trivia_provider.dart';

part 'intro_screen_manager.freezed.dart';
part 'intro_screen_manager.g.dart';

@freezed
class IntroState with _$IntroState {
  const factory IntroState({
    required TriviaCategory category,
  }) = _IntroState;
}

@riverpod
class IntroScreenManager extends _$IntroScreenManager {
  @override
  IntroState build() {
    final triviaState = ref.watch(triviaProvider);
    final triviaNotifier = ref.read(triviaProvider.notifier);

    return IntroState(
        category:
            triviaNotifier.getCategoryById(triviaState.categoryId ?? -1) ??
                const TriviaCategory(id: -1, name: "all"));
  }
}
