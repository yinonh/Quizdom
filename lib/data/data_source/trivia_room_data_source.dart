import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/core/constants/app_constant.dart';

class TriviaRoomDataSource {
  // Creates a new trivia room
  static Future<void> createRoom({
    required String roomId,
    required int questionCount,
    required int categoryId,
    required String categoryName,
    required String difficulty,
    required bool isPublic,
  }) async {
    await FirebaseFirestore.instance.collection('triviaRooms').doc(roomId).set({
      'questionCount': questionCount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'difficulty': difficulty,
      'isPublic': isPublic,
      'createdAt': FieldValue.serverTimestamp(),
      'users': [],
      'topUsers': [],
    });
  }

  // Updates room details (e.g., updating user scores or other room details)
  static Future<void> updateRoom({
    required String roomId,
    Map<String, dynamic>? updates,
  }) async {
    if (updates != null) {
      await FirebaseFirestore.instance
          .collection('triviaRooms')
          .doc(roomId)
          .update(updates);
    }
  }

  // Deletes a trivia room
  static Future<void> deleteRoom(String roomId) async {
    await FirebaseFirestore.instance
        .collection('triviaRooms')
        .doc(roomId)
        .delete();
  }

  // Allows a user to join a trivia room
  static Future<void> joinRoom({
    required String roomId,
    required String userId,
    String? userName,
  }) async {
    final roomRef =
        FirebaseFirestore.instance.collection('triviaRooms').doc(roomId);

    // Add the user to the room
    await roomRef.update({
      'users': FieldValue.arrayUnion([
        {
          'id': userId,
          'name': userName,
          'score': 0, // Initial score for the user
        }
      ]),
    });
  }

  // Updates the scores of users in a trivia room
  static Future<void> updateUserScore({
    required String roomId,
    required String userId,
    required int newScore,
  }) async {
    final roomRef =
        FirebaseFirestore.instance.collection('triviaRooms').doc(roomId);

    // Fetch the current room data
    final snapshot = await roomRef.get();
    if (!snapshot.exists) throw Exception("Room not found");

    final data = snapshot.data() as Map<String, dynamic>;
    final users = (data['users'] as List<dynamic>).cast<Map<String, dynamic>>();

    // Update the user's score
    final updatedUsers = users.map((user) {
      if (user['id'] == userId) {
        return {
          ...user,
          'score': newScore,
        };
      }
      return user;
    }).toList();

    // Update the top 10 users based on scores
    final topUsers = updatedUsers.map((user) => user).toList()
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final top10 = topUsers.take(AppConstant.topUsersLength).toList();

    // Update the database
    await roomRef.update({
      'users': updatedUsers,
      'topUsers': top10,
    });
  }
}
