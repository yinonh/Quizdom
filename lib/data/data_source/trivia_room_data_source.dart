import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/data/models/trivia_achievements.dart';
import 'package:trivia/data/models/trivia_room.dart';

class TriviaRoomDataSource {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final _roomsCollection = _firestore.collection('triviaRooms');

  // BOT_USER_ID constant
  static const String BOT_USER_ID = "-1";

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
    Map<String, int> userScores = {userIds[0]: 0, userIds[1]: 0};

    // Initialize empty map for userAchievements
    Map<String, TriviaAchievements> userAchievements = {};

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
      userAchievements: userAchievements,
    );

    // Convert to JSON then set the createdAt field to use Firestore's server timestamp.
    final roomData = triviaRoom.toJson();
    roomData['createdAt'] = FieldValue.serverTimestamp();

    await _roomsCollection.doc(roomId).set(roomData);
  }

  static Future<TriviaRoom?> getRoomById(String roomId) async {
    try {
      final doc = await _roomsCollection.doc(roomId).get();

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

  // Start game by updating the room status
  static Future<void> startGame(String roomId) async {
    await _roomsCollection.doc(roomId).update({
      'currentStage': const GameStageConverter().toJson(GameStage.active),
      'currentQuestionStartTime': FieldValue.serverTimestamp(),
    });
  }

  // Update timestamp if missing
  static Future<void> updateQuestionStartTime(String roomId) async {
    await _roomsCollection
        .doc(roomId)
        .update({'currentQuestionStartTime': FieldValue.serverTimestamp()});
  }

  // Store user's answer for a question
  static Future<void> storeUserAnswer(
      String roomId, String userId, int questionIndex, int answerIndex) async {
    await _roomsCollection
        .doc(roomId)
        .update({'userAnswers.$userId.$questionIndex': answerIndex});
  }

  // Update user score when they answer correctly
  static Future<void> updateUserScore(
      String roomId, String userId, int questionIndex, double timeLeft) async {
    final roomSnapshot = await _roomsCollection.doc(roomId).get();
    if (!roomSnapshot.exists) return;

    final roomData = roomSnapshot.data() as Map<String, dynamic>;
    final Map<String, dynamic> scores = roomData['userScores'] ?? [];

    // Calculate points based on time left (more time = more points)
    final points = (timeLeft * 10).round();

    // Update score
    scores[userId] = (scores[userId] as int) + points;
    await _roomsCollection.doc(roomId).update({'userScores': scores});
  }

  // Increment missed questions counter
  static Future<void> updateMissedQuestions(
      String roomId, String userId) async {
    await _roomsCollection
        .doc(roomId)
        .update({'userMissedQuestions.$userId': FieldValue.increment(1)});
  }

  // Move to review stage
  static Future<void> moveToReviewStage(String roomId) async {
    await _roomsCollection.doc(roomId).update(
      {
        'currentStage':
            const GameStageConverter().toJson(GameStage.questionReview),
      },
    );
  }

  // Move to next question or complete the game
  static Future<void> moveToNextQuestion(
      String roomId, int currentQuestionIndex, int totalQuestions) async {
    if (currentQuestionIndex < totalQuestions - 1) {
      await _roomsCollection.doc(roomId).update({
        'currentStage': const GameStageConverter().toJson(GameStage.active),
        'currentQuestionIndex': currentQuestionIndex + 1,
        'currentQuestionStartTime': FieldValue.serverTimestamp(),
      });
    } else {
      await _roomsCollection.doc(roomId).update({
        'currentStage': const GameStageConverter().toJson(GameStage.completed),
      });
    }
  }

  // End the game
  static Future<void> endGame(String roomId, String absentUserId) async {
    final roomDoc = await _roomsCollection.doc(roomId).get();
    if (!roomDoc.exists) {
      return;
    }

    final roomData = roomDoc.data() as Map<String, dynamic>;
    final userScores = Map<String, int>.from(roomData['userScores'] ?? []);

    // Find the index of the absent user and set their score to -1
    userScores[absentUserId] = -1;

    // Update the room document with the new scores and game stage
    await _roomsCollection.doc(roomId).update({
      'currentStage': const GameStageConverter().toJson(GameStage.canceled),
      'userScores': userScores,
    });
  }

  static Future<void> updateUserAchievements(
    String roomId,
    String userId,
    TriviaAchievements achievements,
  ) async {
    try {
      // First get the current userAchievements map
      final roomDoc = await _roomsCollection.doc(roomId).get();
      if (!roomDoc.exists) {
        return;
      }

      final data = roomDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> userAchievements =
          (data['userAchievements'] as Map<String, dynamic>?) ?? {};

      // Update the achievements for this specific user
      userAchievements[userId] = achievements.toJson();

      // Save back to Firestore
      await _roomsCollection.doc(roomId).update({
        'userAchievements': userAchievements,
      });
    } catch (e) {
      print('Error updating user achievements: $e');
    }
  }

  // Check if all users have answered the current question - modified to handle bot users
  static Future<bool> checkAllUsersAnswered(
      String roomId, List<String> users, int questionIndex) async {
    final roomSnapshot = await _roomsCollection.doc(roomId).get();
    if (!roomSnapshot.exists) return false;

    final roomData = roomSnapshot.data() as Map<String, dynamic>;
    final userAnswers = roomData['userAnswers'] as Map<String, dynamic>? ?? {};

    for (final userId in users) {
      final hasAnswered = userAnswers.containsKey(userId) &&
          (userAnswers[userId] as Map<String, dynamic>?)
                  ?.containsKey(questionIndex.toString()) ==
              true;

      if (!hasAnswered) {
        return false;
      }
    }

    return true;
  }

  // Get room updates as stream
  static Stream<TriviaRoom?> getRoomStream(String roomId) {
    return _roomsCollection.doc(roomId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;

      final roomData = snapshot.data() as Map<String, dynamic>;
      return TriviaRoom.fromJson({
        ...roomData,
        'roomId': snapshot.id,
      });
    });
  }

  // Parse user answers from Firestore document
  static Map<String, Map<int, int>> parseUserAnswers(
      Map<String, dynamic> roomData) {
    final Map<String, Map<int, int>> userAnswers = {};
    if (roomData['userAnswers'] != null) {
      final firestoreUserAnswers =
          roomData['userAnswers'] as Map<String, dynamic>;
      firestoreUserAnswers.forEach((userId, answers) {
        userAnswers[userId] = {};
        if (answers is Map<String, dynamic>) {
          answers.forEach((qIndexStr, answerVal) {
            final qIndex = int.tryParse(qIndexStr);
            if (qIndex != null && answerVal is int) {
              userAnswers[userId]![qIndex] = answerVal;
            }
          });
        }
      });
    }
    return userAnswers;
  }

  // Update lastSeen to make it more efficient with bots
  static Future<void> updateLastSeen(String roomId, String userId) async {
    await FirebaseFirestore.instance
        .collection('triviaRooms')
        .doc(roomId)
        .update({
      'lastSeen.$userId': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> setAutoStartTime(
      String roomId, DateTime startTime) async {
    await FirebaseFirestore.instance
        .collection('triviaRooms')
        .doc(roomId)
        .update({
      'autoStartTime': startTime,
    });
  }

  static Future<Map<String, DateTime>> getUserLastSeen(String roomId) async {
    final doc = await FirebaseFirestore.instance
        .collection('triviaRooms')
        .doc(roomId)
        .get();
    if (!doc.exists) return {};

    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final Map<String, dynamic> lastSeenData = data['lastSeen'] ?? {};

    Map<String, DateTime> result = {};
    lastSeenData.forEach((key, value) {
      if (value is Timestamp) {
        result[key] = value.toDate();
      }
    });

    return result;
  }

  // Check for absent user - modified to ignore bots
  static Future<String?> checkForAbsentUser(
      String roomId, List<String> users) async {
    final lastSeenMap = await getUserLastSeen(roomId);
    final now = DateTime.now();

    // Check if any user hasn't updated in the last 6 seconds
    for (final user in users) {
      // Skip checking for BOT_USER_ID, bots are always "present"
      if (user == BOT_USER_ID) continue;

      if (!lastSeenMap.containsKey(user)) continue;

      final lastUpdate = lastSeenMap[user]!;
      if (now.difference(lastUpdate).inSeconds > 6) {
        return user; // Found an absent user
      }
    }

    return null;
  }

  static Future<bool> checkUserPresence(
      String roomId, List<String> users) async {
    // First check if we have any bot users
    if (users.contains(BOT_USER_ID)) {
      // Remove BOT_USER_ID from the check list - bots are always "present"
      final realUsers = users.where((user) => user != BOT_USER_ID).toList();
      if (realUsers.isEmpty)
        return true; // If all users are bots, everyone is present

      // Continue checking only real users
      users = realUsers;
    }

    final lastSeenMap = await getUserLastSeen(roomId);
    final now = DateTime.now();

    // Check if all users have updated their lastSeen within the last 10 seconds
    for (final user in users) {
      if (!lastSeenMap.containsKey(user)) return false;

      final lastUpdate = lastSeenMap[user]!;
      if (now.difference(lastUpdate).inSeconds > 10) return false;
    }

    return true;
  }
}
