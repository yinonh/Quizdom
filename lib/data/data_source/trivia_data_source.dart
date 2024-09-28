import 'package:dio/dio.dart';
import 'package:trivia/core/constants/api_endpoints.dart';

class TriviaDataSource {
  final Dio client;

  TriviaDataSource({required this.client});

  Future<Map<String, dynamic>> requestToken() async {
    final response = await client
        .get(ApiEndpoints.apiToken, queryParameters: {"command": "request"});
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to get session token');
    }
  }

  Future<Map<String, dynamic>> fetchCategories(String? token) async {
    final response = await client
        .get(ApiEndpoints.apiCategory, queryParameters: {"token": token});
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load trivia categories');
    }
  }

  Future<Map<String, dynamic>> fetchTriviaQuestions(
      int? categoryId, String? token) async {
    final response = await client.get(
      ApiEndpoints.apiTrivia,
      queryParameters: {
        "amount": 10,
        "category": categoryId,
        "encode": "base64",
        "token": token,
      },
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load trivia questions');
    }
  }
}
