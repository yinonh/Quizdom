import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/data/models/user_preference.dart';

class UserPreferenceDataSource {
  static final _collection =
      FirebaseFirestore.instance.collection('availablePlayers');

  // Create new user preference
  static Future<void> createUserPreference({
    required String userId,
    required UserPreference preference,
  }) async {
    await _collection.doc(userId).set(
          preference.copyWith(createdAt: DateTime.now()).toJson(),
        );
  }

  static Stream<Map<String, UserPreference>> watchAvailableUsers() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) => {
              for (var doc in snapshot.docs)
                doc.id: UserPreference.fromJson(doc.data())
            });
  }

  static Future<Map<String, UserPreference>> getAvailableUsers() async {
    // Fetch the snapshot once
    final snapshot =
        await _collection.orderBy('createdAt', descending: true).get();

    // Convert the snapshot to a map
    final Map<String, UserPreference> userPreferences = {};
    for (var doc in snapshot.docs) {
      userPreferences[doc.id] = UserPreference.fromJson(doc.data());
    }

    return userPreferences;
  }

  // Update existing user preference
  static Future<void> updateUserPreference({
    required String userId,
    required UserPreference updatedPreference,
  }) async {
    final docRef = _collection.doc(userId);

    await docRef.set(
      updatedPreference.copyWith(createdAt: DateTime.now()).toJson(),
      SetOptions(merge: true),
    );
  }

  // Get user preference
  static Future<UserPreference?> getUserPreference(String userId) async {
    final doc = await _collection.doc(userId).get();

    if (doc.exists) {
      return UserPreference.fromJson(doc.data()!);
    }

    return null;
  }

  // Delete user preference
  static Future<void> deleteUserPreference(String userId) async {
    await _collection.doc(userId).delete();
  }

  // Get all available players
  static Stream<List<UserPreference>> getAllAvailablePlayers() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => UserPreference.fromJson(doc.data()))
            .toList());
  }

  // Get available players with filters
  static Stream<List<UserPreference>> getFilteredAvailablePlayers({
    int? categoryId,
    int? questionCount,
    String? difficulty,
  }) {
    var query = _collection.orderBy('createdAt', descending: true);

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (questionCount != null) {
      query = query.where('questionCount', isEqualTo: questionCount);
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => UserPreference.fromJson(doc.data()))
        .toList());
  }
}
