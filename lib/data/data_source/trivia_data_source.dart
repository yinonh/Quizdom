import 'package:dio/dio.dart';
import 'package:trivia/core/constants/api_endpoints.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/core/utils/enums/difficulty.dart';

class TriviaDataSource {
  static final Dio client = DioClient.instance;

  static Future<Map<String, dynamic>> requestToken() async {
    final response = await client
        .get(ApiEndpoints.apiToken, queryParameters: {"command": "request"});
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to get session token');
    }
  }

  static Future<Map<String, dynamic>> fetchCategories(String? token) async {
    final response = await client
        .get(ApiEndpoints.apiCategory, queryParameters: {"token": token});
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load trivia categories');
    }
  }

  static Future<Map<String, dynamic>> fetchTriviaQuestions(
      {int? category, String? token, Difficulty? difficulty}) async {
    final response = await client.get(
      ApiEndpoints.apiTrivia,
      queryParameters: {
        "amount": AppConstant.numberOfQuestions,
        "category": category == -1 ? "" : category,
        "difficulty": difficulty?.value,
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
