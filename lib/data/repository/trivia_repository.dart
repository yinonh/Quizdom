import 'package:trivia/data/data_source/trivia_data_source.dart';

import 'dart:convert';

import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/trivia_response.dart';

class TriviaRepository {
  final TriviaDataSource dataSource;

  TriviaRepository({required this.dataSource});

  Future<String> getToken() async {
    final data = await dataSource.requestToken();
    return data['token'] as String;
  }

  Future<TriviaCategories> getCategories(String? token) async {
    final data = await dataSource.fetchCategories(token);
    TriviaCategories categories = TriviaCategories.fromJson(data);
    categories = categories.copyWith(triviaCategories: [
      const TriviaCategory(name: "All", id: -1),
      ...?categories.triviaCategories,
    ]);
    return categories;
  }

  TriviaCategory? getCategoryById(TriviaCategories categories, int id) {
    return categories.triviaCategories?.firstWhere(
      (category) => category.id == id,
      orElse: () => const TriviaCategory(id: -1, name: 'Unknown'),
    );
  }

  Future<TriviaResponse> getTriviaQuestions(
      int? categoryId, String? token) async {
    final data = await dataSource.fetchTriviaQuestions(categoryId, token);
    List decodedResults = (data['results'] as List).map((result) {
      return decodeFields(result);
    }).toList();
    return TriviaResponse.fromJson({
      'response_code': data['response_code'],
      'results': decodedResults,
    });
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
}
