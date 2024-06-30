import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivia/models/user_achievements.dart';

part 'user_provider.freezed.dart';

part 'user_provider.g.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
    String? uid,
    String? name,
    String? email,
    File? userImage,
    String? avatar,
    required UserAchievements achievements,
  }) = _UserState;
}

@Riverpod(keepAlive: true)
class User extends _$User {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  UserState build() {
    return const UserState(
      achievements: UserAchievements(
        correctAnswers: 0,
        wrongAnswers: 0,
        unanswered: 0,
        sumResponseTime: 0.0,
      ),
    );
  }

  void resetAchievements() {
    state = state.copyWith(
      achievements: const UserAchievements(
          correctAnswers: 0,
          wrongAnswers: 0,
          unanswered: 0,
          sumResponseTime: 0),
    );
  }

  void updateAchievements(
      {required AchievementField field, double? sumResponseTime}) {
    UserAchievements updatedAchievements;

    switch (field) {
      case AchievementField.correctAnswers:
        updatedAchievements = state.achievements.copyWith(
          correctAnswers: state.achievements.correctAnswers + 1,
        );
        break;
      case AchievementField.wrongAnswers:
        updatedAchievements = state.achievements.copyWith(
          wrongAnswers: state.achievements.wrongAnswers + 1,
        );
        break;
      case AchievementField.unanswered:
        updatedAchievements = state.achievements.copyWith(
          unanswered: state.achievements.unanswered + 1,
        );
        break;
    }
    state = state.copyWith(achievements: updatedAchievements);

    updatedAchievements = state.achievements.copyWith(
      sumResponseTime:
          state.achievements.sumResponseTime + (sumResponseTime ?? 10),
    );

    state = state.copyWith(achievements: updatedAchievements);
  }

  Future<void> setImage(File? image) async {
    if (image != null) {
      // Get the application's document directory
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/user_image.png';

      // Save the image to the directory
      final savedImage = await image.copy(imagePath);

      // Save the image path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_image_path', savedImage.path);

      state = state.copyWith(userImage: savedImage);
    } else {
      // Remove image path from SharedPreferences if image is null
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_image_path');

      state = state.copyWith(userImage: null);
    }
  }

  Future<void> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    if (uid != null) {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final name = userData['name'];
        final email = userData['email'];
        String? imagePath = prefs.getString('user_image_path');
        String? avatar = prefs.getString('user_avatar');
        if (imagePath != null && await File(imagePath).exists()) {
          state = state.copyWith(
            avatar: avatar,
            userImage: File(imagePath),
            uid: uid,
            name: name,
            email: email,
          );
        } else {
          state = state.copyWith(
            avatar: avatar,
            uid: uid,
            name: name,
            email: email,
          );
        }
      } else {
        // Handle case where user document doesn't exist in Firestore
      }
    } else {
      // Handle case where uid is null
    }
  }

  Future<void> saveUser(String uid, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
    });

    state = state.copyWith(uid: uid, name: name, email: email);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = state.uid;

    if (uid != null) {
      await _firestore.collection('users').doc(uid).delete();
      await prefs.remove('uid');
      await prefs.remove('name');
      await prefs.remove('email');

      state = state.copyWith(uid: null, name: null, email: null);
    }
  }

  Future<String?> setAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(avatar: prefs.getString('user_avatar'));
    return null;
  }
}
