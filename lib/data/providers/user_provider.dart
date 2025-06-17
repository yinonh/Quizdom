import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/date_time_extansion.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/data_source/user_statistics_data_source.dart';
import 'package:trivia/data/models/trivia_user.dart';

part 'user_provider.freezed.dart';
part 'user_provider.g.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
    required User? firebaseUser,
    required TriviaUser currentUser,
    @Default(false) bool imageLoading,
    bool? loginNewDayInARow,
  }) = _UserState;
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  UserState build() {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return UserState(
      firebaseUser: firebaseUser,
      currentUser: firebaseUser != null
          ? TriviaUser.fromFirebaseUser(firebaseUser)
          : TriviaUser.createDefault(uid: "", name: "Guest"),
      imageLoading: false,
    );
  }

  // Handle daily login rewards
  void onClaim(int award) async {
    await updateCoins(award);
    state = state.copyWith(loginNewDayInARow: false);
  }

  // Update coins and sync with Firestore
  Future<void> updateCoins(int amount) async {
    final newCoins = state.currentUser.coins + amount;
    final updatedUser = state.currentUser.withUpdatedCoins(newCoins);

    // Update local state first for immediate UI feedback
    state = state.copyWith(currentUser: updatedUser);

    // Then sync with Firestore
    try {
      await UserDataSource.updateCoins(updatedUser.uid, newCoins);
    } catch (e) {
      // Revert local state if Firestore update fails
      state = state.copyWith(
          currentUser: state.currentUser
              .withUpdatedCoins(state.currentUser.coins - amount));
      rethrow;
    }
  }

  // Initialize user from Firestore or create new one
  Future<void> initializeUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    try {
      // Try to get existing user from Firestore
      final existingUser = await UserDataSource.getUserById(firebaseUser.uid);

      if (existingUser == null) {
        // Create new user
        await _createNewUser(firebaseUser);
        return;
      }

      // Update login status based on last login
      bool? loginNewDayInARow;
      if (existingUser.lastLogin?.isYesterday ?? false) {
        loginNewDayInARow = true;
      } else if (existingUser.lastLogin?.isOlderThanYesterday ?? true) {
        loginNewDayInARow = false;
      }

      // Update state with existing user
      state = state.copyWith(
        firebaseUser: firebaseUser,
        currentUser: existingUser,
        loginNewDayInARow: loginNewDayInARow,
      );

      // Update last login in Firestore
      await UserDataSource.updateLastLogin(firebaseUser.uid, DateTime.now());
    } catch (e) {
      print('Error initializing user: $e');
      // Fallback: create new user
      await _createNewUser(firebaseUser);
    }
  }

  // Create new user with default values
  Future<void> _createNewUser(User firebaseUser) async {
    try {
      final newUser = TriviaUser.fromFirebaseUser(firebaseUser);

      // Save to Firestore
      await UserDataSource.saveUser(newUser);

      // Create user statistics
      await UserStatisticsDataSource.createUserStatistics(firebaseUser.uid);

      // Update local state
      state = state.copyWith(
        firebaseUser: firebaseUser,
        currentUser: newUser,
        loginNewDayInARow: null,
      );
    } catch (e) {
      print('Error creating new user: $e');
      rethrow;
    }
  }

  // Update user details
  Future<void> updateUserDetails({
    required String uid,
    required String name,
  }) async {
    final updatedUser = state.currentUser.copyWith(name: name);

    // Update local state
    state = state.copyWith(currentUser: updatedUser);

    // Update Firestore
    await UserDataSource.updateName(uid, name);
  }

  // Add XP to user
  Future<void> addXp(double xp) async {
    final updatedUser = state.currentUser.withAddedXp(xp);

    // Update local state
    state = state.copyWith(currentUser: updatedUser);

    // Update Firestore
    await UserDataSource.updateXp(updatedUser.uid, updatedUser.userXp);
  }

  // Handle image upload
  Future<void> setImage(File? image) async {
    if (image == null) return;

    state = state.copyWith(imageLoading: true);

    try {
      final imageUrl =
          await UserDataSource.updateUserImage(state.currentUser.uid, image);

      // Delete existing avatar if present
      await UserDataSource.deleteUserAvatar(state.currentUser.uid);

      final updatedUser = state.currentUser.copyWith(imageUrl: imageUrl);
      state = state.copyWith(currentUser: updatedUser, imageLoading: false);
    } catch (e) {
      state = state.copyWith(imageLoading: false);
      rethrow;
    }
  }

  // Add trivia category to recent list
  Future<void> addTriviaCategory(int categoryId) async {
    final updatedUser = state.currentUser.withUpdatedCategories(categoryId);

    // Update local state
    state = state.copyWith(currentUser: updatedUser);

    // Update Firestore
    await UserDataSource.updateRecentCategories(
      updatedUser.uid,
      updatedUser.recentTriviaCategories,
    );
  }

  // Set avatar (remove image)
  Future<void> setAvatar() async {
    final userId = state.currentUser.uid;
    if (userId.isEmpty) return;

    await UserDataSource.deleteUserImageIfExists(userId);

    final updatedUser = state.currentUser.copyWith(imageUrl: null);
    state = state.copyWith(currentUser: updatedUser);
  }

  // Authentication methods
  Future<UserCredential> signIn(String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUser(String email, String password) async {
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      final newUser = TriviaUser.fromFirebaseUser(user);
      await UserDataSource.saveUser(newUser);
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

    if (user == null || user.uid.isEmpty) {
      throw AssertionError('User UID cannot be null after sign-in.');
    }

    // Handle new Google user
    if (userCredential.additionalUserInfo?.isNewUser == true) {
      final newUser = TriviaUser.fromFirebaseUser(user);
      await UserDataSource.saveUser(newUser);
      await UserStatisticsDataSource.createUserStatistics(user.uid);
    }

    // Update state with Firebase user
    state = state.copyWith(firebaseUser: user);
    return userCredential.additionalUserInfo;
  }

  bool isGoogleSignIn() {
    if (state.firebaseUser?.providerData.isEmpty ?? true) {
      return false;
    }

    return state.firebaseUser!.providerData
        .any((userInfo) => userInfo.providerId == 'google.com');
  }

  Future<void> reauthenticateUserWithPassword(String password) async {
    final firebaseUser = state.firebaseUser;
    if (firebaseUser == null) {
      throw Exception("User not logged in. Cannot re-authenticate.");
    }
    if (firebaseUser.email == null) {
      throw Exception("User email is not available. Cannot re-authenticate with password.");
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: password,
      );
      await firebaseUser.reauthenticateWithCredential(credential);
      print("User re-authenticated successfully with password.");
    } on FirebaseAuthException catch (e) {
      print("Error re-authenticating with password: ${e.code} - ${e.message}");
      rethrow; // Rethrow to be caught by UI
    } catch (e) {
      print("Unexpected error during password re-authentication: $e");
      rethrow;
    }
  }

  Future<void> reauthenticateUserWithGoogle() async {
    final firebaseUser = state.firebaseUser;
    if (firebaseUser == null) {
      throw Exception("User not logged in. Cannot re-authenticate.");
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the Google Sign-In flow
        throw FirebaseAuthException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Google Sign-In aborted by user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await firebaseUser.reauthenticateWithCredential(credential);
      print("User re-authenticated successfully with Google.");
    } on FirebaseAuthException catch (e) {
      print("Error re-authenticating with Google: ${e.code} - ${e.message}");
      rethrow; // Rethrow to be caught by UI
    } catch (e) {
      print("Unexpected error during Google re-authentication: $e");
      rethrow;
    }
  }

  Future<void> deleteUser({bool isRetryAfterReauthentication = false}) async {
    final firebaseUser = state.firebaseUser;
    if (firebaseUser == null) {
      throw Exception("User not logged in. Cannot delete account.");
    }

    final currentUserId = state.currentUser.uid;

    try {
      // 1. Delete from Firebase Authentication
      await firebaseUser.delete();

      // 2. Delete user data from Firestore
      if (currentUserId.isEmpty) {
        // This case should ideally not happen if a user is logged in
        print("Warning: currentUserId is empty during deleteUser for firebaseUser: ${firebaseUser.uid}. Using firebaseUser.uid for data deletion.");
        await UserDataSource.clearUser(firebaseUser.uid);
        await UserStatisticsDataSource.deleteUserStatistics(firebaseUser.uid);
      } else {
        await UserDataSource.clearUser(currentUserId);
        await UserStatisticsDataSource.deleteUserStatistics(currentUserId);
      }

      // 3. Sign out
      final wasGoogleSignIn = isGoogleSignIn(); // Check before firebaseUser becomes null
      await FirebaseAuth.instance.signOut();
      if (wasGoogleSignIn) {
        await GoogleSignIn().signOut();
      }

      // 4. Update local state
      state = state.copyWith(
        firebaseUser: null,
        currentUser: TriviaUser.createDefault(uid: "", name: "Guest"),
        loginNewDayInARow: null,
      );
      print("User account deleted and signed out successfully.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (isRetryAfterReauthentication) {
          print("Delete user error: Still requires recent login even after re-authentication attempt. Aborting.");
          throw Exception(
              "Failed to delete account. Please try logging out and in again.");
        } else {
          print("Delete user error: Requires recent login. Prompting for re-authentication.");
          rethrow; // Rethrow the specific FirebaseAuthException to be caught by the UI
        }
      } else {
        print('Firebase Auth error during user deletion: ${e.code} - ${e.message}');
        rethrow;
      }
    } catch (e) {
      print('Error deleting user account: $e');
      // Attempt to sign out locally if something went wrong mid-process
      if (FirebaseAuth.instance.currentUser != null) {
        try {
          await FirebaseAuth.instance.signOut();
          if (isGoogleSignIn()) await GoogleSignIn().signOut();
        } catch (signOutError) {
          print("Error during fallback sign out: $signOutError");
        }
      }
      // Reset local state as a safety measure
      state = state.copyWith(
        firebaseUser: null,
        currentUser: TriviaUser.createDefault(uid: "", name: "Guest"),
        loginNewDayInARow: null,
      );
      rethrow;
    }
  }
}
