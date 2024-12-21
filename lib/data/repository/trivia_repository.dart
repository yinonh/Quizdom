import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/data_source/trivia_data_source.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/question.dart';

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  final dioClient = ref.watch(dioProvider);
  final dataSource = TriviaDataSource(client: dioClient);
  return TriviaRepository(dataSource: dataSource);
});

class TriviaRepository {
  final TriviaDataSource dataSource;

  // Private static instance
  static TriviaRepository? _instance;

  // Private constructor
  TriviaRepository._internal({required this.dataSource});

  // Factory constructor to return the singleton instance
  factory TriviaRepository({required TriviaDataSource dataSource}) {
    return _instance ??= TriviaRepository._internal(dataSource: dataSource);
  }

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

  Future<List<Question>?> getTriviaQuestions(
      GeneralTriviaRoom? triviaRoom, String? token) async {
    final data = await dataSource.fetchTriviaQuestions(triviaRoom, token);

    final List<Question> questions = (data['results'] as List).map((result) {
      final decodedResult = decodeFields(result);
      return Question.fromJson(decodedResult);
    }).toList();

    return questions;
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
