import 'package:dio/dio.dart';
import 'package:trivia/core/constants/api_endpoints.dart';
import 'package:trivia/data/models/general_trivia_room.dart';

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

  // // // Helper function to check if a suitable room exists
  // // Future<bool> _checkRoomExists(int categoryId) async {
  // //   final rooms = await FirebaseFirestore.instance
  // //       .collection('triviaRooms')
  // //       .where('categoryId', isEqualTo: categoryId)
  // //       .where('questionCount', isEqualTo: 10)
  // //       .where('difficulty', isEqualTo: 'medium')
  // //       .where('isPublic', isEqualTo: true)
  // //       .get();
  // //
  // //   return rooms.docs.isNotEmpty;
  // // }
  //
  // Future<Map<String, dynamic>> fetchCategories(String? token) async {
  //   final response = await client
  //       .get(ApiEndpoints.apiCategory, queryParameters: {"token": token});
  //   if (response.statusCode == 200) {
  //     final categories = response.data;
  //
  //     // Check or create trivia rooms for each category
  //     final categoryList = categories['trivia_categories'] as List<dynamic>;
  //     for (var category in categoryList) {
  //       final categoryId = category['id'] as int;
  //
  //       // Check for an existing public room with 10 questions and medium difficulty
  //       final roomExists = false; //await _checkRoomExists(categoryId);
  //
  //       // If the room does not exist, create one
  //       if (!roomExists) {
  //         await TriviaRoomDataSource().createRoom(
  //           roomId: 'room_$categoryId', // Generate a unique room ID
  //           questionCount: 10,
  //           categoryId: categoryId,
  //           categoryName: category['name'],
  //           difficulty: 'medium',
  //           isPublic: true,
  //         );
  //       }
  //     }
  //     return categories;
  //   } else {
  //     throw Exception('Failed to load trivia categories');
  //   }
  // }

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
      GeneralTriviaRoom? triviaRoom, String? token) async {
    final response = await client.get(
      ApiEndpoints.apiTrivia,
      queryParameters: {
        "amount": 10,
        "category": triviaRoom?.categoryId == -1 ? "" : triviaRoom?.categoryId,
        "difficulty": "medium", //triviaRoom?.difficulty,
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
