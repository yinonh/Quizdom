import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/data/models/user_statistics.dart';

class UserStatisticsDataSource {
  static Future createUserStatistics(String userId) async {
    await FirebaseFirestore.instance
        .collection('userStatistics')
        .doc(userId)
        .set(const UserStatistics().toJson());
  }

  static Future updateUserStatistics({
    required String userId,
    required UserStatistics updatedStatistics,
  }) async {
    await FirebaseFirestore.instance
        .collection('userStatistics')
        .doc(userId)
        .update(updatedStatistics.toJson());
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
