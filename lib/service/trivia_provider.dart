import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/models/trivia_categories.dart';
import 'package:trivia/models/trivia_response.dart';
import 'package:trivia/service/server.dart';

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

@Riverpod(keepAlive: true)
class Trivia extends _$Trivia {
  @override
  TriviaState build() {
    return TriviaState(
      client: ref.watch(dioProvider),
      categoryId: null,
      token: null,
    );
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
      categories = categories.copyWith(triviaCategories: [
        const TriviaCategory(name: "All", id: -1),
        ...?categories.triviaCategories
      ]);
      return categories;
    } else {
      throw Exception('Failed to load trivia data');
    }
  }

  void setCategory(int categoryId) {
    if (categoryId != -1) {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  Map<String, dynamic> decodeFields(Map<String, dynamic> result) {
    return {
      'difficulty': utf8.decode(base64.decode(result['difficulty'])),
      'category': utf8.decode(base64.decode(result['category'])),
      'question': utf8.decode(base64.decode(result['question'])),
      'correct_answer': utf8.decode(base64.decode(result['correct_answer'])),
      'incorrect_answers': (result['incorrect_answers'] as List).map((answer) {
        return utf8.decode(base64.decode(answer));
      }).toList(),
    };
  }

  Future<TriviaResponse> getTriviaQuestions() async {
    final response = await state.client.get(
      "api.php",
      queryParameters: {
        "amount": 10,
        "category": state.categoryId,
        "encode": "base64",
        "token": state.token,
      },
    );
    if (response.statusCode == 200) {
      List decodedResults = (response.data['results'] as List).map((result) {
        return decodeFields(result);
      }).toList();

      return TriviaResponse.fromJson({
        'response_code': response.data['response_code'],
        'results': decodedResults
      });
    } else {
      throw Exception('Failed to load trivia questions');
    }
  }
}
