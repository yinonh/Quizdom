import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/data/models/user_preference.dart';

class UserPreferenceDataSource {
  static final _collection =
      FirebaseFirestore.instance.collection('availablePlayers');

  /// Creates or updates the user’s preference document.
  /// Make sure to include "matchedUserId": null in the document.
  static Future<void> createUserPreference({
    required String userId,
    required UserPreference preference,
  }) async {
    final data = preference.copyWith(createdAt: DateTime.now()).toJson();
    data['matchedUserId'] = null;
    await _collection.doc(userId).set(data);
  }

  /// Returns a stream that watches the current user's document and maps it to the matchedUserId field.
  static Stream<String?> watchMatchedUserId(String userId) {
    return _collection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      return data?['matchedUserId'] as String?;
    });
  }

  /// Removes currentUserId from the other user's matchedUserId field if present.
  static Future<void> removeMatchFromOther(
      String currentUserId, String otherUserId) async {
    final doc = await _collection.doc(otherUserId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['matchedUserId'] == currentUserId) {
        await _collection.doc(otherUserId).update({'matchedUserId': null});
        print(
            '🔄 [removeMatchFromOther] Removed $currentUserId from user $otherUserId');
      }
    }
  }

  /// Finds a match for the given user and updates both documents in a transaction.
  /// The [excludedIds] list contains IDs that should be excluded from matching.
  static Future<String?> findMatch(String userId,
      {List<String>? excludedIds}) async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get current user's document
      DocumentReference currentRef = _collection.doc(userId);
      DocumentSnapshot currentSnapshot = await transaction.get(currentRef);

      if (!currentSnapshot.exists) {
        print('⚠️ [findMatch] User $userId not found in availablePlayers.');
        return null;
      }

      final currentUserPref = UserPreference.fromJson(
          currentSnapshot.data()! as Map<String, dynamic>);

      // Check if current user is already matched
      if (currentUserPref.matchedUserId != null) {
        print('⚠️ [findMatch] User $userId is already matched.');
        return null;
      }

      print('✅ [findMatch] Current user preference: $currentUserPref');

      // Build query for potential matches
      List<String> idsToExclude = [userId];
      if (excludedIds != null) {
        idsToExclude.addAll(excludedIds);
      }

      final excludeList =
          idsToExclude.length > 10 ? idsToExclude.sublist(0, 10) : idsToExclude;

      Query query = _collection
          .where(FieldPath.documentId, whereNotIn: excludeList)
          .where('matchedUserId', isNull: true);

      QuerySnapshot potentialMatchesSnapshot = await query.get();
      print(
          '📊 [findMatch] Total potential matches found: ${potentialMatchesSnapshot.docs.length}');

      List<DocumentSnapshot> validMatches = [];
      for (var doc in potentialMatchesSnapshot.docs) {
        final userPref =
            UserPreference.fromJson(doc.data()! as Map<String, dynamic>);
        print(
            '🔍 Checking potential match: ${doc.id} - Preferences: $userPref');

        // Evaluate matching conditions
        bool categoryMatch = (currentUserPref.categoryId == null ||
            currentUserPref.categoryId == -1 ||
            userPref.categoryId == null ||
            userPref.categoryId == -1 ||
            currentUserPref.categoryId == userPref.categoryId);
        bool questionCountMatch = (currentUserPref.questionCount == null ||
            currentUserPref.questionCount == -1 ||
            userPref.questionCount == null ||
            userPref.questionCount == -1 ||
            currentUserPref.questionCount == userPref.questionCount);
        bool difficultyMatch = (currentUserPref.difficulty == null ||
            currentUserPref.difficulty == "-1" ||
            userPref.difficulty == null ||
            userPref.difficulty == "-1" ||
            currentUserPref.difficulty == userPref.difficulty);

        if (categoryMatch && questionCountMatch && difficultyMatch) {
          validMatches.add(doc);
        }
      }

      if (validMatches.isEmpty) {
        print('⚠️ [findMatch] No suitable match found for user $userId.');
        return null;
      }

      // Choose a random valid match
      DocumentSnapshot selectedDoc =
          validMatches[Random().nextInt(validMatches.length)];
      String selectedMatchId = selectedDoc.id;

      // Re-check selected match's status within the transaction
      DocumentSnapshot selectedMatchSnapshot =
          await transaction.get(_collection.doc(selectedMatchId));
      UserPreference selectedMatchPref = UserPreference.fromJson(
          selectedMatchSnapshot.data()! as Map<String, dynamic>);

      if (selectedMatchPref.matchedUserId != null) {
        print(
            '⚠️ [findMatch] Selected match $selectedMatchId is already matched.');
        return null;
      }

      // Atomically update both documents
      transaction.update(currentRef, {'matchedUserId': selectedMatchId});
      transaction
          .update(_collection.doc(selectedMatchId), {'matchedUserId': userId});
      print('🔄 [findMatch] Updated documents: $userId ↔️ $selectedMatchId');

      return selectedMatchId;
    });
  }

  /// Deletes the user's preference document.
  static Future<void> deleteUserPreference(String userId) async {
    print('🗑️ [deleteUserPreference] Removing user: $userId');
    await _collection.doc(userId).delete();
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
