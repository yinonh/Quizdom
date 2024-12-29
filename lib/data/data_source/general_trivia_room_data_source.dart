import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/data/models/general_trivia_room.dart';

class GeneralTriviaRoomDataSource {
  static Future<List<GeneralTriviaRoom>> fetchAllGeneralRooms() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('generalTriviaRooms').get();

    // Map the documents to TriviaRoom instances
    return snapshot.docs.map((doc) {
      final data = doc.data(); // Retrieve the document data
      return GeneralTriviaRoom.fromJson({
        ...data, // Spread the document data
        'roomId': doc.id, // Add the document ID as 'roomId'
      });
    }).toList();
  }

  static Future<void> updateRoom({
    required String roomId,
    Map<String, dynamic>? updates,
  }) async {
    if (updates != null) {
      await FirebaseFirestore.instance
          .collection('generalTriviaRooms')
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

  Future<Map<String, int>> updateUserScore({
    required String roomId,
    required String userId,
    required int newScore,
  }) async {
    final roomRef =
        FirebaseFirestore.instance.collection('generalTriviaRooms').doc(roomId);

    // Fetch the current room data
    final snapshot = await roomRef.get();
    if (!snapshot.exists) throw Exception("Room not found");

    final data = snapshot.data() as Map<String, dynamic>;

    // Get the topUsers map
    final Map<String, dynamic> topUsers =
        (data['topUsers'] as Map<String, dynamic>).cast<String, dynamic>();

    // Update the user's score or add the user if not present
    topUsers[userId] = newScore;

    // Sort the map by scores in descending order
    final sortedEntries = topUsers.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    // Take the top 5 users
    final top5 = Map<String, int>.fromEntries(
      sortedEntries.take(5).map((e) => MapEntry(e.key, e.value as int)),
    );

    // Update the database
    await roomRef.update({
      'topUsers': top5,
    });

    // Return the updated top users
    return top5;
  }
}
