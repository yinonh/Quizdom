import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/server.dart';

import 'package:trivia/models/trivia_categories.dart';
import 'package:trivia/models/trivia_response.dart';

part 'trivia_provider.freezed.dart';
part 'trivia_provider.g.dart';

@freezed
class TriviaState with _$TriviaState {
  const factory TriviaState({
    required Dio client,
    required String? token,
    required int? categoryId,
  }) = _TriviaState;
}

@riverpod
class Trivia extends _$Trivia {
  @override
  TriviaState build() {
    final client = ref.watch(dioProvider);
    return TriviaState(
        client: ref.watch(dioProvider), categoryId: null, token: null);
  }

  Future<void> setToken() async {
    final response = await state.client
        .get("api_token.php", queryParameters: {"command": "request"});
    if (response.statusCode == 200) {
      state = state.copyWith(token: response.data['token'] as String);
    } else {
      throw Exception('Failed to get session token');
    }
  }

  Future<TriviaCategories> getCategories() async {
    final response = await state.client
        .get("api_category.php", queryParameters: {"token": state.token});
    if (response.statusCode == 200) {
      TriviaCategories categories = TriviaCategories.fromJson(response.data);
      return categories;
    } else {
      throw Exception('Failed to load trivia data');
    }
  }

  void setCategory(int categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  Future<TriviaResponse> getTriviaQuestions() async {
    final response = await state.client.get(
      "https://opentdb.com/api.php",
      queryParameters: {
        "amount": 10,
        "category": state.categoryId,
        "type": "multiple",
        "token": state.token,
      },
    );
    if (response.statusCode == 200) {
      return TriviaResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load trivia questions');
    }
  }
}
