import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/models/user.dart';
import 'package:trivia/data/models/user_achievements.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivia/core/constants/constant_strings.dart';

part 'user_provider.freezed.dart';
part 'user_provider.g.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
    required TriviaUser currentUser,
    required bool imageLoading,
  }) = _UserState;
}

@Riverpod(keepAlive: true)
class User extends _$User {
  late final UserDataSource _userDataSource;

  @override
  UserState build() {
    _userDataSource = ref.read(userDataSourceProvider.notifier);

    return UserState(
      currentUser: TriviaUser(
        achievements: const UserAchievements(
          correctAnswers: 0,
          wrongAnswers: 0,
          unanswered: 0,
          sumResponseTime: 0.0,
        ),
        lastLogin: DateTime.now(),
        recentTriviaCategories: [],
        trophies: [],
        userXp: 0.0,
      ),
      imageLoading: false,
    );
  }

  TriviaUser updateCurrentUser({
    String? uid,
    String? name,
    String? email,
    File? userImage,
    String? avatar,
    UserAchievements? achievements,
    DateTime? lastLogin,
    List<int>? recentTriviaCategories,
    List<int>? trophies,
    double? userXp,
  }) {
    return state.currentUser.copyWith(
      uid: uid ?? state.currentUser.uid,
      name: name ?? state.currentUser.name,
      email: email ?? state.currentUser.email,
      userImage: userImage ?? state.currentUser.userImage,
      avatar: avatar ?? state.currentUser.avatar,
      achievements: achievements ?? state.currentUser.achievements,
      lastLogin: lastLogin ?? state.currentUser.lastLogin,
      recentTriviaCategories:
          recentTriviaCategories ?? state.currentUser.recentTriviaCategories,
      trophies: trophies ?? state.currentUser.trophies,
      userXp: userXp ?? state.currentUser.userXp,
    );
  }

  Future<void> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final userDoc = await _userDataSource.getUserDocument(userId);

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final name = userData['name'];
        final email = FirebaseAuth.instance.currentUser?.email;

        // Updated lastLogin to handle Timestamp
        final lastLoginTimestamp = userData['lastLogin'] as Timestamp;
        final lastLogin = lastLoginTimestamp.toDate();

        final recentTriviaCategories =
            List<int>.from(userData['recentTriviaCategories']);
        final trophies = List<int>.from(userData['trophies']);
        final userXp = userData['userXp'] as double;

        String? imagePath;
        if (prefs.containsKey(Strings.croppedUserImagePathKey)) {
          imagePath = prefs.getString(Strings.croppedUserImagePathKey);
        }
        String? avatar = prefs.getString(Strings.userAvatarKey);
        File? userImage = imagePath != null && await File(imagePath).exists()
            ? File(imagePath)
            : null;

        final updatedUser = updateCurrentUser(
          uid: userId,
          name: name,
          email: email,
          userImage: userImage,
          avatar: avatar,
          lastLogin: lastLogin,
          recentTriviaCategories: recentTriviaCategories,
          trophies: trophies,
          userXp: userXp,
        );

        state = state.copyWith(currentUser: updatedUser);
      }
    }
  }

  Future<void> saveUser(String uid, String name, String email) async {
    await _userDataSource.saveUser(uid, name);
    state = state.copyWith(
      currentUser: updateCurrentUser(uid: uid, name: name, email: email),
    );
  }

  Future<void> updateUserDetails({
    required String uid,
    required String name,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name,
    });
    final updatedUser = updateCurrentUser(
      uid: uid,
      name: name,
    );
    state = state.copyWith(currentUser: updatedUser);
  }

  void addXp(double xp) async {
    final updatedUser =
        updateCurrentUser(userXp: state.currentUser.userXp + xp);
    state = state.copyWith(currentUser: updatedUser);

    await _userDataSource.updateUser(
        userId: state.currentUser.uid!, userXp: updatedUser.userXp);
  }

  Future<void> setImage(File? image) async {
    state = state.copyWith(imageLoading: true);

    if (image != null) {
      await _userDataSource.updateUserImage(state.currentUser.uid!, image);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Strings.croppedUserImagePathKey, image.path);

      // Check if an image already exists in Firestore, if yes, delete it
      await _userDataSource.deleteUserAvatar(state.currentUser.uid!);

      final updatedUser = updateCurrentUser(userImage: image);
      state = state.copyWith(currentUser: updatedUser, imageLoading: false);
    }
  }

  Future<void> updateLastLogin() async {
    final now = DateTime.now();
    final updatedUser = updateCurrentUser(lastLogin: now);
    state = state.copyWith(currentUser: updatedUser);

    await _userDataSource.updateUser(
        userId: state.currentUser.uid!, lastLogin: DateTime.now());
  }

  void addTriviaCategory(int categoryId) async {
    List<int> recentCategories =
        List.from(state.currentUser.recentTriviaCategories);
    recentCategories.remove(categoryId);
    recentCategories.insert(0, categoryId);

    if (recentCategories.length > 4) {
      recentCategories.removeLast();
    }

    final updatedUser =
        state.currentUser.copyWith(recentTriviaCategories: recentCategories);
    state = state.copyWith(currentUser: updatedUser);

    await _userDataSource.updateUser(
        userId: state.currentUser.uid!,
        recentTriviaCategories: recentCategories);
  }

  Future<void> clearUser() async {
    if (state.currentUser.uid != null) {
      await _userDataSource.clearUser(state.currentUser.uid!);

      final updatedUser = updateCurrentUser(uid: null, name: null, email: null);
      state = state.copyWith(currentUser: updatedUser);
    }
  }

  Future<String?> setAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final avatarSvg = prefs.getString(Strings.userAvatarKey) ?? "";
    final userId = state.currentUser.uid;

    if (userId == null) return null;

    // Upload the avatar SVG to Firebase Storage and get the download URL
    final avatarUrl =
        await _userDataSource.uploadAvatarToStorage(userId, avatarSvg);

    // Update the avatar URL in Firestore
    await _userDataSource.updateUser(userId: userId, avatarUrl: avatarUrl);

    // Remove the locally stored cropped user image
    await prefs.remove(Strings.croppedUserImagePathKey);

    // Check if an image already exists in Firestore, if yes, delete it
    await _userDataSource.deleteUserImageIfExists(userId);

    // Update the local state with the new avatar and remove the image
    final updatedUser =
        state.currentUser.copyWith(avatar: avatarSvg, userImage: null);
    state = state.copyWith(currentUser: updatedUser);

    return null;
  }

  void resetAchievements() async {
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
  }) async {
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
      sumResponseTime: updatedAchievements.sumResponseTime +
          (field != AchievementField.unanswered
              ? (sumResponseTime ?? 10.0)
              : 10),
    );

    final updatedUser = updateCurrentUser(achievements: updatedAchievements);
    state = state.copyWith(currentUser: updatedUser);

    // await _userDataSource.updateUser(
    //     userId: state.currentUser.uid!, achievements: updatedAchievements);
  }
}
