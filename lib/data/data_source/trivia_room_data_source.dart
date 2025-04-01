import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/data/models/trivia_room.dart';

class TriviaRoomDataSource {
  // Creates a new trivia room
  static Future<void> createRoom({
    required String roomId,
    required int? questionCount,
    required int? categoryId,
    required String? difficulty,
    required bool isPublic,
    required List<String> userIds,
    required String hostUserId,
  }) async {
    // Initialize scores array with same length as users array, filled with 0
    List<int> userScores = List.filled(userIds.length, 0);

    final triviaRoom = TriviaRoom(
      roomId: roomId,
      hostUserId: hostUserId,
      questionCount: questionCount,
      categoryId: categoryId,
      difficulty: difficulty,
      isPublic: isPublic,
      createdAt: DateTime.now(),
      users: userIds,
      userScores: userScores,
      currentStage: GameStage.created,
      currentQuestionIndex: 0,
      currentQuestionStartTime: null,
      questionDuration: 10,
      userMissedQuestions: {},
    );

    // Convert to JSON then set the createdAt field to use Firestore's server timestamp.
    final roomData = triviaRoom.toJson();
    roomData['createdAt'] = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection('triviaRooms')
        .doc(roomId)
        .set(roomData);
  }

  static Future<TriviaRoom?> getRoomById(String roomId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('triviaRooms')
          .doc(roomId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return TriviaRoom.fromJson({
        ...data,
        'roomId': doc.id,
      });
    } catch (e) {
      print('Error retrieving trivia room: $e');
      return null;
    }
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

  static Stream<List<TriviaRoom>> watchAvailableRooms() {
    return FirebaseFirestore.instance
        .collection('triviaRooms')
        .where('users', isLessThan: [
          {}, {} // This checks for arrays with length less than 2
        ])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return TriviaRoom.fromJson({
              ...data,
              'roomId': doc.id,
            });
          }).toList();
        });
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
