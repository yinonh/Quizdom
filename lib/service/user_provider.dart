import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivia/models/user.dart';
import 'package:trivia/models/user_achievements.dart';

part 'user_provider.freezed.dart';
part 'user_provider.g.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
    required TriviaUser currentUser,
  }) = _UserState;
}

@Riverpod(keepAlive: true)
class User extends _$User {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  UserState build() {
    return const UserState(
      currentUser: TriviaUser(
        achievements: UserAchievements(
          correctAnswers: 0,
          wrongAnswers: 0,
          unanswered: 0,
          sumResponseTime: 0.0,
        ),
      ),
    );
  }

  TriviaUser updateCurrentUser({
    String? uid,
    String? name,
    String? email,
    File? userImage,
    String? avatar,
    UserAchievements? achievements,
  }) {
    return state.currentUser.copyWith(
      uid: uid ?? state.currentUser.uid,
      name: name ?? state.currentUser.name,
      email: email ?? state.currentUser.email,
      userImage: userImage ?? state.currentUser.userImage,
      avatar: avatar ?? state.currentUser.avatar,
      achievements: achievements ?? state.currentUser.achievements,
    );
  }

  void resetAchievements() {
    final updatedUser = updateCurrentUser(
      achievements: const UserAchievements(
        correctAnswers: 0,
        wrongAnswers: 0,
        unanswered: 0,
        sumResponseTime: 0.0,
      ),
    );
    state = state.copyWith(currentUser: updatedUser);
  }

  void updateAchievements({
    required AchievementField field,
    double? sumResponseTime,
  }) {
    UserAchievements updatedAchievements;

    switch (field) {
      case AchievementField.correctAnswers:
        updatedAchievements = state.currentUser.achievements.copyWith(
          correctAnswers: state.currentUser.achievements.correctAnswers + 1,
        );
        break;
      case AchievementField.wrongAnswers:
        updatedAchievements = state.currentUser.achievements.copyWith(
          wrongAnswers: state.currentUser.achievements.wrongAnswers + 1,
        );
        break;
      case AchievementField.unanswered:
        updatedAchievements = state.currentUser.achievements.copyWith(
          unanswered: state.currentUser.achievements.unanswered + 1,
        );
        break;
    }

    updatedAchievements = updatedAchievements.copyWith(
      sumResponseTime:
          updatedAchievements.sumResponseTime + (sumResponseTime ?? 10.0),
    );

    final updatedUser = updateCurrentUser(achievements: updatedAchievements);
    state = state.copyWith(currentUser: updatedUser);
  }

  Future<void> setImage(File? image) async {
    final imagePath = image?.path;
    final updatedUser = updateCurrentUser(userImage: image);

    if (image != null && imagePath != null) {
      state = state.copyWith(currentUser: updatedUser);

      // Save the image path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cropped_user_image_path', imagePath);
    } else {
      // Remove image path from SharedPreferences if image is null
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cropped_user_image_path');

      state = state.copyWith(currentUser: updatedUser);
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
        String? imagePath;
        if (prefs.containsKey('cropped_user_image_path')) {
          imagePath = prefs.getString('cropped_user_image_path');
        }
        String? avatar = prefs.getString('user_avatar');
        File? userImage = imagePath != null && await File(imagePath).exists()
            ? File(imagePath)
            : null;

        final updatedUser = updateCurrentUser(
          uid: uid,
          name: name,
          email: email,
          userImage: userImage,
          avatar: avatar,
        );

        state = state.copyWith(currentUser: updatedUser);
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

    final updatedUser = updateCurrentUser(uid: uid, name: name, email: email);
    state = state.copyWith(currentUser: updatedUser);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = state.currentUser.uid;

    if (uid != null) {
      await _firestore.collection('users').doc(uid).delete();
      await prefs.remove('uid');
      await prefs.remove('name');
      await prefs.remove('email');

      final updatedUser = updateCurrentUser(uid: null, name: null, email: null);
      state = state.copyWith(currentUser: updatedUser);
    }
  }

  Future<String?> setAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cropped_user_image_path');

    final updatedUser = state.currentUser.copyWith(
      avatar: prefs.getString('user_avatar'),
      userImage: null,
    );

    state = state.copyWith(currentUser: updatedUser);
    return null;
  }
}
