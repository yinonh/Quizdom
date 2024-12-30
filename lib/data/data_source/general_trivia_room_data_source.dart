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

    // Check if user already exists in top users
    if (topUsers.containsKey(userId)) {
      final currentScore = topUsers[userId] as int;
      // Only update if the new score is higher than current score
      if (newScore <= currentScore) {
        // Return current top users without any changes if new score isn't higher
        return Map<String, int>.from(topUsers);
      }
    }

    // If we have less than 5 users, add the new score
    if (topUsers.length < 5) {
      topUsers[userId] = newScore;
    } else {
      // If user is not in top 5, check if their score qualifies
      if (!topUsers.containsKey(userId)) {
        // Find the lowest score in top 5
        final lowestScore = topUsers.values
            .map((v) => v as int)
            .reduce((min, score) => score < min ? score : min);

        // Only add if new score is higher than the lowest score
        if (newScore > lowestScore) {
          // Remove the user with lowest score
          final userToRemove = topUsers.entries
              .firstWhere((entry) => entry.value == lowestScore)
              .key;
          topUsers.remove(userToRemove);

          // Add the new user
          topUsers[userId] = newScore;
        } else {
          // If score doesn't qualify for top 5, return current top users without updating database
          return Map<String, int>.from(topUsers);
        }
      } else {
        // User is in top 5 and we already checked above that new score is higher
        topUsers[userId] = newScore;
      }
    }

    // Sort the map by scores in descending order
    final sortedEntries = topUsers.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    // Create the top 5 map
    final top5 = Map<String, int>.fromEntries(
      sortedEntries.take(5).map((e) => MapEntry(e.key, e.value as int)),
    );

    // Only update the database if we made changes
    await roomRef.update({
      'topUsers': top5,
    });

    // Return the updated top users
    return top5;
  }
}
