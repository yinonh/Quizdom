import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/core/utils/fluttermoji/fluttermoji_assets/fluttermojimodel.dart';
import 'package:trivia/data/models/trivia_user.dart';

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

          // Use fromJson to map the data to TriviaUser
          return TriviaUser.fromJson({
            ...userData,
            'uid': userId,
            'email':
                FirebaseAuth.instance.currentUser?.email, // Add current email
          });
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
      'fluttermojiOptions': defaultFluttermojiOptions,
      'trophies': [],
      'userXp': 0.0,
      'coins': 100,
    });
  }

  static Future<void> updateUser({
    required String userId,
    double? userXp,
    String? avatarUrl,
    DateTime? lastLogin,
    List<int>? recentTriviaCategories,
    String? name,
    int? coins,
  }) async {
    // Initialize the updates map
    Map<String, dynamic> updates = {};

    // Add fields to the map only if they are not null
    if (userXp != null) {
      updates['userXp'] = userXp;
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
    if (coins != null) {
      updates['coins'] = coins;
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
