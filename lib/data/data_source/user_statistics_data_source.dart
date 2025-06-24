import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/models/user_statistics.dart';

class UserStatisticsDataSource {
  static Future createUserStatistics(String userId) async {
    await FirebaseFirestore.instance
        .collection('userStatistics')
        .doc(userId)
        .set(const UserStatistics().toJson());
  }

  static Future<void> clearUserStatistics(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('userStatistics')
          .doc(userId)
          .delete();
    } catch (e) {
      logger.e('Error clearing user statistics: $e');
      rethrow;
    }
  }

  static Future<void> updateUserStatistics({
    required String userId,
    required UserStatistics updatedStatistics,
  }) async {
    final docRef =
        FirebaseFirestore.instance.collection('userStatistics').doc(userId);

    await docRef.set(
      updatedStatistics.toJson(),
      SetOptions(merge: true), // Merge with existing data or create new doc.
    );
  }

  static Future<UserStatistics?> getUserStatistics(String userId) async {
    final userStatisticsDoc = await FirebaseFirestore.instance
        .collection('userStatistics')
        .doc(userId)
        .get();

    if (userStatisticsDoc.exists) {
      return UserStatistics.fromJson(userStatisticsDoc.data()!);
    }

    return null;
  }

  static Future<bool> userStatisticsExists(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('userStatistics')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      logger.e('Error checking if user statistics exist: $e');
      return false; // Assume not exists on error
    }
  }

  static Future<Map<TriviaUser, int>> getTopUsersByScore() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('userStatistics')
        .orderBy('totalScore', descending: true)
        .limit(10)
        .get();

    final Map<String, int> topUsersMap = {};
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final totalScore = data['totalScore'] as int? ?? 0;
      topUsersMap[doc.id] = totalScore;
    }
    Map<TriviaUser, int> topUsers = {};
    for (String userId in topUsersMap.keys.toList()) {
      final userForId = await UserDataSource.getUserById(userId);
      if (userForId != null) {
        topUsers[userForId] = topUsersMap[userId]!;
      }
    }
    return topUsers;
  }
}
