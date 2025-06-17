import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/models/trivia_user.dart';

class UserDataSource {
  static final _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Get user document reference
  static DocumentReference<Map<String, dynamic>> _getUserDocRef(String userId) {
    return _usersCollection.doc(userId);
  }

  // Get user document snapshot
  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(
      String userId) async {
    return await _getUserDocRef(userId).get();
  }

  // Get TriviaUser by ID using the model's fromJson
  static Future<TriviaUser?> getUserById(String? id) async {
    try {
      final userId = id ?? FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return null;

      final userDoc = await getUserDocument(userId);

      if (!userDoc.exists || userDoc.data() == null) return null;

      final userData = userDoc.data()!;

      // Add the uid and current email to the data
      userData['uid'] = userId;
      userData['email'] =
          userData['email'] ?? FirebaseAuth.instance.currentUser?.email;

      return TriviaUser.fromJson(userData);
    } catch (e) {
      logger.e('Error getting user by ID: $e');
      return null;
    }
  }

  // Save new user using the model's serialization
  static Future<void> saveUser(TriviaUser user) async {
    try {
      await _getUserDocRef(user.uid).set(user.toFirestoreMap());
    } catch (e) {
      logger.e('Error saving user: $e');
      rethrow;
    }
  }

  // Update user using the model's serialization
  static Future<void> updateUser(TriviaUser user) async {
    try {
      await _getUserDocRef(user.uid).update(user.toFirestoreMap());
    } catch (e) {
      logger.e('Error updating user: $e');
      rethrow;
    }
  }

  // Partial update - only update specific fields
  static Future<void> updateUserFields({
    required String userId,
    Map<String, dynamic>? updates,
  }) async {
    if (updates == null || updates.isEmpty) return;

    try {
      await _getUserDocRef(userId).update(updates);
    } catch (e) {
      logger.e('Error updating user fields: $e');
      rethrow;
    }
  }

  // Convenience methods for common updates
  static Future<void> updateCoins(String userId, int coins) async {
    await updateUserFields(userId: userId, updates: {'coins': coins});
  }

  static Future<void> updateXp(String userId, double xp) async {
    await updateUserFields(userId: userId, updates: {'userXp': xp});
  }

  static Future<void> updateLastLogin(String userId, DateTime lastLogin) async {
    await updateUserFields(userId: userId, updates: {'lastLogin': lastLogin});
  }

  static Future<void> updateName(String userId, String name) async {
    await updateUserFields(userId: userId, updates: {'name': name});
  }

  static Future<void> updateRecentCategories(
      String userId, List<int> categories) async {
    await updateUserFields(
        userId: userId, updates: {'recentTriviaCategories': categories});
  }

  // Image handling methods
  static Future<String> updateUserImage(String userId, File image) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('user_images/$userId');
      final uploadTask = await storageRef.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await updateUserFields(
          userId: userId, updates: {'userImage': downloadUrl});
      return downloadUrl;
    } catch (e) {
      logger.e('Error updating user image: $e');
      rethrow;
    }
  }

  static Future<void> deleteUserImageIfExists(String userId) async {
    try {
      final userDoc = await getUserDocument(userId);
      final userData = userDoc.data();

      if (userData?['userImage'] != null) {
        await updateUserFields(
            userId: userId, updates: {'userImage': FieldValue.delete()});
      }
    } catch (e) {
      logger.e('Error deleting user image: $e');
    }
  }

  static Future<void> deleteUserAvatarIfExists(String userId) async {
    try {
      final userDoc = await getUserDocument(userId);
      final userData = userDoc.data();

      if (userData?['userAvatar'] != null) {
        await updateUserFields(
            userId: userId, updates: {'userAvatar': FieldValue.delete()});
      }
    } catch (e) {
      logger.e('Error deleting user avatar: $e');
    }
  }

  static Future<void> deleteUserImage(String userId) async {
    await updateUserFields(
        userId: userId, updates: {'userImage': FieldValue.delete()});
  }

  static Future<void> deleteUserAvatar(String userId) async {
    await updateUserFields(
        userId: userId, updates: {'userAvatar': FieldValue.delete()});
  }

  // Delete user completely
  static Future<void> clearUser(String userId) async {
    try {
      await _getUserDocRef(userId).delete();
    } catch (e) {
      logger.e('Error clearing user: $e');
      rethrow;
    }
  }

  // Check if user exists
  static Future<bool> userExists(String userId) async {
    try {
      final userDoc = await getUserDocument(userId);
      return userDoc.exists;
    } catch (e) {
      logger.e('Error checking if user exists: $e');
      return false;
    }
  }
}
