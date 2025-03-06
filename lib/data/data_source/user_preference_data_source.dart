import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/data_source/trivia_data_source.dart';
import 'package:trivia/data/data_source/trivia_room_data_source.dart';
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
    await _collection.doc(userId).set(data);
  }

  /// Returns a stream that watches the current user's document and maps it to the matchedUserId field.
  static Stream<Map<String, dynamic>> watchUserPreference(String userId) {
    return _collection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return {};
      final data = snapshot.data()!;
      return {
        'matchedUserId': data['matchedUserId'] as String?,
        'triviaRoomId': data['triviaRoomId'] as String?,
        'ready': (data['ready'] ?? false) as bool
      };
    });
  }

  /// Removes currentUserId from the other user's matchedUserId field if present.
  static Future<void> removeMatchFromOther(
      String currentUserId, String otherUserId) async {
    final doc = await _collection.doc(otherUserId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['matchedUserId'] == currentUserId) {
        await _collection
            .doc(otherUserId)
            .update({'matchedUserId': null, "ready": null});
        logger.i(
            '🔄 [removeMatchFromOther] Removed $currentUserId from user $otherUserId');
      }
    }
  }

  static Future<void> clearMatch(String currentUserId) async {
    try {
      await _collection
          .doc(currentUserId)
          .update({'matchedUserId': null, 'ready': null});
    } catch (_) {
      logger.e('other user data didnt deleted');
    }
  }

  static Future<void> setUserReady(String currentUserId, String? token) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore.runTransaction((transaction) async {
      // Get current user's document
      final currentUserDoc =
          await transaction.get(_collection.doc(currentUserId));
      if (!currentUserDoc.exists) return;

      final currentUserPref = UserPreference.fromJson(currentUserDoc.data()!);
      if (currentUserPref.matchedUserId == null) return;

      // Get matched user's document
      final matchedUserDoc = await transaction
          .get(_collection.doc(currentUserPref.matchedUserId!));
      if (!matchedUserDoc.exists) return;

      final matchedUserPref = UserPreference.fromJson(matchedUserDoc.data()!);

      // Set current user as ready
      transaction.update(_collection.doc(currentUserId), {'ready': true});

      // If both users are ready, create trivia room
      if (matchedUserPref.ready == true) {
        // Merge preferences according to the new logic
        final (questionCount, categoryId, difficulty) =
            _mergePreferences(currentUserPref, matchedUserPref);

        // Get category name if categoryId is not null
        String? categoryName;
        if (categoryId != null) {
          // You might want to implement a way to get the category name
          // This is just a placeholder
          categoryName = "Category Name";
        }

        // Generate room ID
        final roomId = firestore.collection('triviaRooms').doc().id;

        // Create the room with user IDs
        List<String> userIds = [currentUserId, currentUserPref.matchedUserId!];

        // Create the room first without questions
        await TriviaRoomDataSource.createRoom(
          roomId: roomId,
          questionCount: questionCount,
          categoryId: categoryId,
          categoryName: categoryName,
          difficulty: difficulty,
          isPublic: false,
          userIds: userIds,
        );

        // Only the user who initiated the room (current user) fetches the questions
        if (currentUserId == userIds[0]) {
          try {
            // Fetch questions from the API
            final questionsData =
                await TriviaDataSource.fetchTriviaQuestions(categoryId, token);

            // Update the trivia room with the questions data
            await firestore.collection('triviaRooms').doc(roomId).update({
              'questionsData': questionsData,
            });
          } catch (e) {
            print('Error fetching trivia questions: $e');
            // Handle error - maybe set an error state in the room
            await firestore.collection('triviaRooms').doc(roomId).update({
              'error': e.toString(),
            });
          }
        }

        // Update both users with the room ID
        transaction
            .update(_collection.doc(currentUserId), {'triviaRoomId': roomId});
        transaction.update(_collection.doc(currentUserPref.matchedUserId!),
            {'triviaRoomId': roomId});
      }
    });
  }

// Helper function to merge preferences
  static (int?, int?, String?) _mergePreferences(
      UserPreference pref1, UserPreference pref2) {
    // For question count: if either user specified a count, use that
    int? questionCount;
    if (pref1.questionCount != null && pref1.questionCount != -1) {
      questionCount = pref1.questionCount;
    } else if (pref2.questionCount != null && pref2.questionCount != -1) {
      questionCount = pref2.questionCount;
    }

    // For category: if either user specified a category, use that
    int? categoryId;
    if (pref1.categoryId != null && pref1.categoryId != -1) {
      categoryId = pref1.categoryId;
    } else if (pref2.categoryId != null && pref2.categoryId != -1) {
      categoryId = pref2.categoryId;
    }

    // For difficulty: if either user specified a difficulty, use that
    String? difficulty;
    if (pref1.difficulty != null && pref1.difficulty != "-1") {
      difficulty = pref1.difficulty;
    } else if (pref2.difficulty != null && pref2.difficulty != "-1") {
      difficulty = pref2.difficulty;
    }

    return (questionCount, categoryId, difficulty);
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
        logger.i('⚠️ [findMatch] User $userId not found in availablePlayers.');
        return null;
      }

      final currentUserPref = UserPreference.fromJson(
          currentSnapshot.data()! as Map<String, dynamic>);

      // Check if current user is already matched
      if (currentUserPref.matchedUserId != null) {
        logger.w('⚠️ [findMatch] User $userId is already matched.');
        return null;
      }

      logger.i('✅ [findMatch] Current user preference: $currentUserPref');

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
      logger.i(
          '📊 [findMatch] Total potential matches found: ${potentialMatchesSnapshot.docs.length}');

      List<DocumentSnapshot> validMatches = [];
      for (var doc in potentialMatchesSnapshot.docs) {
        final userPref =
            UserPreference.fromJson(doc.data()! as Map<String, dynamic>);
        logger.i(
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
        logger.w('⚠️ [findMatch] No suitable match found for user $userId.');
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
        logger.w(
            '⚠️ [findMatch] Selected match $selectedMatchId is already matched.');
        return null;
      }

      // Atomically update both documents
      transaction.update(
          currentRef, {'matchedUserId': selectedMatchId, "ready": null});
      transaction.update(_collection.doc(selectedMatchId),
          {'matchedUserId': userId, "ready": null});
      logger.i('🔄 [findMatch] Updated documents: $userId ↔️ $selectedMatchId');

      return selectedMatchId;
    });
  }

  /// Deletes the user's preference document.
  static Future<void> deleteUserPreference(String userId) async {
    logger.i('🗑️ [deleteUserPreference] Removing user: $userId');
    await _collection.doc(userId).delete();
  }

  static Future<void> cleanupUserPreference(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('availablePlayers')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['matchedUserId'] != null) {
          final matchedUserId = data['matchedUserId'] as String;
          await UserPreferenceDataSource.removeMatchFromOther(
              userId, matchedUserId);
        }

        UserPreferenceDataSource.deleteUserPreference(userId);

        print(
            "🧹 Cleaned up user preference for $userId during app lifecycle event");
      }
    } catch (e) {
      print("❌ Error cleaning up user preference: $e");
    }
  }

  static Future<void> recreateUserPreference(String userId) async {
    try {
      // Check if document already exists
      final docSnapshot = await FirebaseFirestore.instance
          .collection('availablePlayers')
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        // Only recreate if it doesn't exist
        await UserPreferenceDataSource.createUserPreference(
          userId: userId,
          preference: UserPreference.empty(),
        );
        logger.i("🔄 Recreated user preference for $userId after app resume");
      }
    } catch (e) {
      logger.e("❌ Error recreating user preference: $e");
    }
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
}
