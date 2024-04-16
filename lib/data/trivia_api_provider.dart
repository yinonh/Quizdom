import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/server.dart';

import 'package:trivia/models/trivia_categories.dart';

part 'trivia_api_provider.g.dart';

@riverpod
class TriviaApi extends _$TriviaApi {
  late Dio client = ref.watch(dioProvider);

  @override
  Future<TriviaCategories> build() async {
    final response = await client.get("api_category.php");
    if (response.statusCode == 200) {
      TriviaCategories x = TriviaCategories.fromJson(response.data);
      return x;
    } else {
      throw Exception('Failed to load trivia data');
    }
  }

  Future<TriviaCategories> getCategories() async {
    final response = await client.get("api_category.php");
    if (response.statusCode == 200) {
      TriviaCategories x = TriviaCategories.fromJson(response.data);
      return x;
    } else {
      throw Exception('Failed to load trivia data');
    }
  }
}
