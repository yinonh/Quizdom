import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralTriviaRoomDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // /// Fetch a trivia room by its ID and deserialize it into a TriviaRoom
  // Future<TriviaRoom?> getRoomById(String roomId) async {
  //   final roomSnapshot =
  //       await firestore.collection('triviaRooms').doc(roomId).get();
  //
  //   if (!roomSnapshot.exists) {
  //     return null; // Return null if the room doesn't exist
  //   }
  //
  //   final data = roomSnapshot.data();
  //   if (data == null) {
  //     return null;
  //   }
  //
  //   TriviaRoom room = TriviaRoom.fromJson(data);
  //
  //   // Deserialize Firestore data into a TriviaRoom object
  //   return room.copyWith(roomId: roomId);
  // }

  Future<void> updateRoom({
    required String roomId,
    Map<String, dynamic>? updates,
  }) async {
    if (updates != null) {
      await firestore
          .collection('generalTriviaRooms')
          .doc(roomId)
          .update(updates);
    }
  }

  // Deletes a trivia room
  Future<void> deleteRoom(String roomId) async {
    await firestore.collection('triviaRooms').doc(roomId).delete();
  }

  // Updates the scores of users in a trivia room
  Future<void> updateUserScore({
    required String roomId,
    required String userId,
    required int newScore,
  }) async {
    final roomRef = firestore.collection('generalTriviaRooms').doc(roomId);

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

    // Update the top 5 users based on scores
    final topUsers = updatedUsers.map((user) => user).toList()
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final top5 = topUsers.take(5).toList();

    // Update the database
    await roomRef.update({
      'users': updatedUsers,
      'topUsers': top5,
    });
  }
}
