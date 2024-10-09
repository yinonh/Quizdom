import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/user_achievements.dart';

part 'user_data_source.freezed.dart';
part 'user_data_source.g.dart';

@freezed
class UserDataSourceState with _$UserDataSourceState {
  const factory UserDataSourceState({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) = _UserDataSourceState;
}

@Riverpod(keepAlive: true)
class UserDataSource extends _$UserDataSource {
  @override
  UserDataSourceState build() {
    return UserDataSourceState(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    );
  }

  Future<DocumentSnapshot> getUserDocument(String userId) async {
    return await state.firestore.collection('users').doc(userId).get();
  }

  Future<void> saveUser(String uid, String name, String email) async {
    final now = DateTime.now();
    await state.firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'lastLogin': now.toIso8601String(),
      'recentTriviaCategories': [],
      'trophies': [],
      'userXp': 0.0,
    });
  }

  Future<void> updateUserXp(String userId, double userXp) async {
    await state.firestore.collection('users').doc(userId).update({
      'userXp': userXp,
    });
  }

  Future<void> updateUserAchievements(
      String userId, UserAchievements achievements) async {
    await state.firestore.collection('users').doc(userId).update({
      'achievements': achievements.toJson(),
    });
  }

  Future<void> resetUserAchievements(String userId) async {
    const defaultAchievements = UserAchievements(
      correctAnswers: 0,
      wrongAnswers: 0,
      unanswered: 0,
      sumResponseTime: 0.0,
    );

    await state.firestore.collection('users').doc(userId).update({
      'achievements': defaultAchievements.toJson(),
    });
  }

  Future<void> updateUserImage(String userId, File image) async {
    final storageRef = state.storage.ref().child('user_images/$userId');
    final uploadTask = await storageRef.putFile(image);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    await state.firestore.collection('users').doc(userId).update({
      'userImage': downloadUrl,
    });
  }

  Future<String> uploadAvatarToStorage(String userId, String avatarSvg) async {
    final storageRef = state.storage.ref().child('user_images/$userId');
    final uploadTask = await storageRef.putString(avatarSvg);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> updateUserAvatar(String userId, String avatarUrl) async {
    await state.firestore.collection('users').doc(userId).update({
      'userAvatar': avatarUrl,
    });
  }

  Future<void> deleteUserImageIfExists(String userId) async {
    final userDoc = await state.firestore.collection('users').doc(userId).get();
    final userImageExists = userDoc.data()?['userImage'] != null;
    if (userImageExists) {
      await state.firestore.collection('users').doc(userId).update({
        'userImage': FieldValue.delete(),
      });
    }
  }

  Future<void> deleteUserImage(String userId) async {
    await state.firestore.collection('users').doc(userId).update({
      'userImage': FieldValue.delete(),
    });
  }

  Future<void> deleteUserAvatar(String userId) async {
    await state.firestore.collection('users').doc(userId).update({
      'userAvatar': FieldValue.delete(),
    });
  }

  Future<void> updateLastLogin(String userId) async {
    final now = DateTime.now();
    await state.firestore.collection('users').doc(userId).update({
      'lastLogin': now.toIso8601String(),
    });
  }

  Future<void> updateRecentTriviaCategories(
      String userId, List<int> categories) async {
    await state.firestore.collection('users').doc(userId).update({
      'recentTriviaCategories': categories,
    });
  }

  Future<void> clearUser(String userId) async {
    await state.firestore.collection('users').doc(userId).delete();
  }
}
