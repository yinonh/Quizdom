// filter_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/core/utils/enums/difficulty.dart';
import 'package:Quizdom/data/models/user_preference.dart';

part 'filter_manager.freezed.dart';
part 'filter_manager.g.dart';

@freezed
class FilterState with _$FilterState {
  const factory FilterState({
    @Default(-1) int? categoryId,
    @Default(-1) int? questionCount,
    Difficulty? difficulty,
  }) = _FilterState;

  factory FilterState.fromUserPreference(UserPreference preference) {
    return FilterState(
      categoryId: preference.categoryId ?? -1,
      questionCount: preference.questionCount ?? -1,
      difficulty: preference.difficulty,
    );
  }

  const FilterState._();

  UserPreference toUserPreference() {
    return UserPreference(
      categoryId: categoryId == -1 ? null : categoryId,
      questionCount: questionCount == -1 ? null : questionCount,
      difficulty: difficulty,
      createdAt: DateTime.now(),
    );
  }
}

@riverpod
class FilterManager extends _$FilterManager {
  @override
  FilterState build() {
    return const FilterState();
  }

  void updateFilters({
    int? categoryId,
    int? questionCount,
    Difficulty? difficulty,
  }) {
    state = state.copyWith(
      categoryId: categoryId ?? state.categoryId,
      questionCount: questionCount ?? state.questionCount,
      difficulty: difficulty ?? state.difficulty,
    );
  }

  void resetFilters() {
    state = const FilterState();
  }

  void initializeFromUserPreference(UserPreference preference) {
    state = FilterState.fromUserPreference(preference);
  }
}
