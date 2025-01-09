import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/data/models/user_statistics.dart';

class UserStatisticsDataSource {
  static Future createUserStatistics(String userId) async {
    await FirebaseFirestore.instance
        .collection('userStatistics')
        .doc(userId)
        .set(const UserStatistics().toJson());
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
}
