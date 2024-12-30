import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/models/user.dart';
import 'package:trivia/data/models/user_achievements.dart';

part 'user_provider.freezed.dart';
part 'user_provider.g.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
    required User? firebaseUser,
    required TriviaUser currentUser,
    required bool imageLoading,
  }) = _UserState;
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  UserState build() {
    return UserState(
      firebaseUser: FirebaseAuth.instance.currentUser,
      currentUser: TriviaUser(
        uid: FirebaseAuth.instance.currentUser?.uid,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? state.currentUser.imageUrl,
      achievements: achievements ?? state.currentUser.achievements,
      lastLogin: lastLogin ?? state.currentUser.lastLogin,
      recentTriviaCategories:
          recentTriviaCategories ?? state.currentUser.recentTriviaCategories,
      trophies: trophies ?? state.currentUser.trophies,
      userXp: userXp ?? state.currentUser.userXp,
    );
  }

  Future<void> initializeUser() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final currentUser = await UserDataSource.getUserById(userId);

      final updatedUser = updateCurrentUser(
        uid: userId,
        name: currentUser?.name,
        email: currentUser?.email,
        imageUrl: currentUser?.imageUrl,
        lastLogin: currentUser?.lastLogin,
        recentTriviaCategories: currentUser?.recentTriviaCategories,
        trophies: currentUser?.trophies,
        userXp: currentUser?.userXp,
      );

      state = state.copyWith(currentUser: updatedUser);
    }
  }

  Future<void> saveUser(String uid, String name, String email) async {
    await UserDataSource.saveUser(uid, name);
    state = state.copyWith(
      currentUser: updateCurrentUser(uid: uid, name: name, email: email),
    );
  }

  Future<void> updateUserDetails({
    required String uid,
    required String name,
  }) async {
    UserDataSource.updateUser(userId: uid, name: name);
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

    await UserDataSource.updateUser(
        userId: state.currentUser.uid!, userXp: updatedUser.userXp);
  }

  Future<void> setImage(File? image) async {
    state = state.copyWith(imageLoading: true);

    if (image != null) {
      final imageUrl =
          await UserDataSource.updateUserImage(state.currentUser.uid!, image);

      // Check if an image already exists in Firestore, if yes, delete it
      await UserDataSource.deleteUserAvatar(state.currentUser.uid!);

      final updatedUser = updateCurrentUser(imageUrl: imageUrl);
      state = state.copyWith(currentUser: updatedUser, imageLoading: false);
    }
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

    await UserDataSource.updateUser(
        userId: state.currentUser.uid!,
        recentTriviaCategories: recentCategories);
  }

  Future<void> clearUser() async {
    if (state.currentUser.uid != null) {
      await UserDataSource.clearUser(state.currentUser.uid!);

      final updatedUser = updateCurrentUser(uid: null, name: null, email: null);
      state = state.copyWith(currentUser: updatedUser);
    }
  }

  Future<void> setAvatar() async {
    final userId = state.currentUser.uid;

    if (userId != null) {
      await UserDataSource.deleteUserImageIfExists(userId);

      // Update the local state with the new avatar and remove the image
      final updatedUser = state.currentUser.copyWith(imageUrl: null);
      state = state.copyWith(currentUser: updatedUser);
    }
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
  }

  Future<UserCredential> signIn(String email, String password) async {
    final userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await initializeUser();
    return userCredential;
  }

  Future<UserCredential> createUser(String email, String password) async {
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      await saveUser(
          user.uid, user.email?.split('@')[0] ?? '', user.email ?? '');
    }
    return userCredential;
  }

  Future<AdditionalUserInfo?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user;

    if (user != null) {
      await initializeUser();
    }
    return userCredential.additionalUserInfo;
  }

  bool isGoogleSignIn() {
    if (state.firebaseUser?.providerData.isEmpty ?? true) {
      return false;
    }
    for (var userInfo in state.firebaseUser!.providerData) {
      if (userInfo.providerId == 'google.com') {
        return true;
      }
    }
    return false;
  }
}
