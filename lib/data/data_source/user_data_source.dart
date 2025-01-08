import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/models/user.dart';
import 'package:trivia/data/models/user_achievements.dart';

class UserDataSource {
  static Future<DocumentSnapshot> getUserDocument(String userId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
  }

  static Future<TriviaUser?> getUserById(String? id) async {
    try {
      final userId = id ?? FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final userDoc = await UserDataSource.getUserDocument(userId);

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final name = userData['name'];
          final email = FirebaseAuth.instance.currentUser?.email;

          final recentTriviaCategories =
              List<int>.from(userData['recentTriviaCategories']);
          final trophies = List<int>.from(userData['trophies']);
          final userXp = userData['userXp'] as double;
          final imageUrl = userData['userImage'];
          final fluttermojiOptions = userData['fluttermojiOptions'];

          return TriviaUser(
              uid: userId,
              name: name,
              email: email,
              imageUrl: imageUrl,
              lastLogin:
                  (FirebaseAuth.instance.currentUser?.metadata.lastSignInTime ??
                      DateTime.now()),
              recentTriviaCategories: recentTriviaCategories,
              trophies: trophies,
              userXp: userXp,
              achievements: const UserAchievements(
                correctAnswers: 0,
                wrongAnswers: 0,
                unanswered: 0,
                sumResponseTime: 0,
              ),
              fluttermojiOptions: fluttermojiOptions);
        }
      }
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  static Future<void> saveUser(String uid, String name) async {
    final now = DateTime.now();
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'lastLogin': now,
      'recentTriviaCategories': [],
      'trophies': [],
      'userXp': 0.0,
    });
  }

  static Future<void> updateUser({
    required String userId,
    double? userXp,
    UserAchievements? achievements,
    String? avatarUrl,
    DateTime? lastLogin,
    List<int>? recentTriviaCategories,
    String? name,
  }) async {
    // Initialize the updates map
    Map<String, dynamic> updates = {};

    // Add fields to the map only if they are not null
    if (userXp != null) {
      updates['userXp'] = userXp;
    }
    if (achievements != null) {
      updates['achievements'] = achievements.toJson();
    }
    if (avatarUrl != null) {
      updates['userAvatar'] = avatarUrl;
    }
    if (lastLogin != null) {
      updates['lastLogin'] = lastLogin;
    }
    if (recentTriviaCategories != null) {
      updates['recentTriviaCategories'] = recentTriviaCategories;
    }
    if (name != null) {
      updates['name'] = name;
    }

    // Only make the update call if there are updates to send
    if (updates.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updates);
    }
  }

  static Future<String> updateUserImage(String userId, File image) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('user_images/$userId');
    final uploadTask = await storageRef.putFile(image);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'userImage': downloadUrl,
    });
    return downloadUrl;
  }

  static Future<void> deleteUserImageIfExists(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userImageExists = userDoc.data()?['userImage'] != null;

    if (userImageExists) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'userImage': FieldValue.delete(),
      });
    }
  }

  static Future<void> deleteUserAvatarIfExists(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userAvatarExists = userDoc.data()?['userAvatar'] != null;
    if (userAvatarExists) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'userAvatar': FieldValue.delete(),
      });
    }
  }

  static Future<void> deleteUserImage(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'userImage': FieldValue.delete(),
    });
  }

  static Future<void> deleteUserAvatar(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'userAvatar': FieldValue.delete(),
    });
  }

  static Future<void> clearUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }
}
