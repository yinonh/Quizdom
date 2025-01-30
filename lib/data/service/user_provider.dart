import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/date_time_extansion.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/models/trivia_user.dart';

part 'user_provider.freezed.dart';
part 'user_provider.g.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
    required User? firebaseUser,
    required TriviaUser currentUser,
    required bool imageLoading,
    bool? loginNewDayInARow,
  }) = _UserState;
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  UserState build() {
    return UserState(
      firebaseUser: FirebaseAuth.instance.currentUser,
      currentUser: TriviaUser(
        uid: FirebaseAuth.instance.currentUser?.uid ?? "",
        lastLogin: DateTime.now(),
        recentTriviaCategories: [],
        userXp: 0.0,
        coins: 100,
      ),
      imageLoading: false,
    );
  }

  void onClaim(int award) async {
    updateCoins(award);
    state = state.copyWith(loginNewDayInARow: false);
  }

  void updateCoins(int amount) async {
    await UserDataSource.updateUser(
        userId: state.currentUser.uid, coins: state.currentUser.coins + amount);
    state = state.copyWith(
        currentUser: state.currentUser
            .copyWith(coins: state.currentUser.coins + amount));
  }

  TriviaUser updateCurrentUser({
    String? uid,
    String? name,
    String? email,
    String? imageUrl,
    DateTime? lastLogin,
    List<int>? recentTriviaCategories,
    double? userXp,
    int? coins,
  }) {
    return state.currentUser.copyWith(
      uid: uid ?? state.currentUser.uid,
      name: name ?? state.currentUser.name,
      email: email ?? state.currentUser.email,
      imageUrl: imageUrl ?? state.currentUser.imageUrl,
      lastLogin: lastLogin ?? state.currentUser.lastLogin,
      recentTriviaCategories:
          recentTriviaCategories ?? state.currentUser.recentTriviaCategories,
      userXp: userXp ?? state.currentUser.userXp,
      coins: coins ?? state.currentUser.coins,
    );
  }

  Future<void> initializeUser() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId != "") {
      final currentUser = await UserDataSource.getUserById(userId);

      final updatedUser = TriviaUser(
          uid: userId,
          name: currentUser?.name,
          email: currentUser?.email,
          imageUrl: currentUser?.imageUrl,
          lastLogin: currentUser?.lastLogin,
          recentTriviaCategories: currentUser?.recentTriviaCategories ?? [],
          userXp: currentUser?.userXp ?? 0,
          coins: currentUser?.coins ?? 0);

      if (updatedUser.lastLogin?.isYesterday ?? false) {
        state =
            state.copyWith(currentUser: updatedUser, loginNewDayInARow: true);
      } else if (updatedUser.lastLogin?.isOlderThanYesterday ?? true) {
        state =
            state.copyWith(currentUser: updatedUser, loginNewDayInARow: false);
      } else {
        state =
            state.copyWith(currentUser: updatedUser, loginNewDayInARow: null);
      }

      await UserDataSource.updateUser(
          userId: userId, lastLogin: DateTime.now());
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
        userId: state.currentUser.uid, userXp: updatedUser.userXp);
  }

  Future<void> setImage(File? image) async {
    state = state.copyWith(imageLoading: true);

    if (image != null) {
      final imageUrl =
          await UserDataSource.updateUserImage(state.currentUser.uid, image);

      // Check if an image already exists in Firestore, if yes, delete it
      await UserDataSource.deleteUserAvatar(state.currentUser.uid);

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
        userId: state.currentUser.uid,
        recentTriviaCategories: recentCategories);
  }

  Future<void> clearUser() async {
    if (state.currentUser.uid != "") {
      await UserDataSource.clearUser(state.currentUser.uid);

      final updatedUser = updateCurrentUser(uid: null, name: null, email: null);
      state = state.copyWith(currentUser: updatedUser);
    }
  }

  Future<void> setAvatar() async {
    final userId = state.currentUser.uid;

    if (userId != "") {
      await UserDataSource.deleteUserImageIfExists(userId);

      // Update the local state with the new avatar and remove the image
      final updatedUser = state.currentUser.copyWith(imageUrl: null);
      state = state.copyWith(currentUser: updatedUser);
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    final userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
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

    if (user == null || user.uid == "") {
      throw AssertionError('User UID cannot be null after sign-in.');
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
