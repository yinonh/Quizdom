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
      'lastLogin': now,
      'recentTriviaCategories': [],
      'trophies': [],
      'userXp': 0.0,
    });
  }

  Future<void> updateUser({
    required String userId,
    double? userXp,
    UserAchievements? achievements,
    String? avatarUrl,
    DateTime? lastLogin,
    List<int>? recentTriviaCategories,
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

    // Only make the update call if there are updates to send
    if (updates.isNotEmpty) {
      await state.firestore.collection('users').doc(userId).update(updates);
    }
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

  Future<void> clearUser(String userId) async {
    await state.firestore.collection('users').doc(userId).delete();
  }
}
