import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/core/utils/date_time_extansion.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added import
import 'package:trivia/data/data_source/user_statistics_data_source.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/core/global_providers/auth_providers.dart';

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
      throw Exception(
          "User email is not available. Cannot re-authenticate with password.");
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

  Future<UserCredential> signInAnonymously() async {
    // This method is now for the *initial* anonymous sign-in on a device installation.
    // It creates the user and stores their UID as the device_guest_uid.
    try {
      // UserDataSource.signInAnonymously calls FirebaseAuth.instance.signInAnonymously()
      // and creates the TriviaUser document.
      final userCredential = await UserDataSource.signInAnonymously();
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Store this new anonymous user's UID as the device_guest_uid
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_guest_uid', firebaseUser.uid);
        logger.i("Stored new device_guest_uid: ${firebaseUser.uid}");

        // Ensure UserStatistics are created if they don't exist
        if (!await UserStatisticsDataSource.userStatisticsExists(firebaseUser.uid)) {
          await UserStatisticsDataSource.createUserStatistics(firebaseUser.uid);
        }

        // Fetch the TriviaUser (which UserDataSource.signInAnonymously should have created)
        final triviaUser = await UserDataSource.getUserById(firebaseUser.uid);

        state = state.copyWith(
          firebaseUser: firebaseUser,
          currentUser: triviaUser ?? TriviaUser.fromFirebaseUser(firebaseUser),
          loginNewDayInARow: null,
        );
      }
      return userCredential;
    } catch (e) {
      logger.e("Error in Auth provider initial signInAnonymously: $e");
      rethrow;
    }
  }

  Future<UserCredential> signInWithDeviceGuestUid(String deviceGuestUid) async {
    logger.i("Attempting to sign in with device_guest_uid: $deviceGuestUid");
    try {
      // Step 1: Call your Firebase Function to get a custom token
      // This is a placeholder for the actual HTTP call.
      // You'll need to use a package like http or dio to make this call.
      // final response = await http.post(
      //   Uri.parse('YOUR_FIREBASE_FUNCTION_URL/getDeviceGuestToken'),
      //   body: {'uid': deviceGuestUid},
      // );

      // if (response.statusCode == 200) {
      //   final customToken = jsonDecode(response.body)['customToken'];
      //   if (customToken == null) {
      //     throw Exception('Custom token was null in function response.');
      //   }

      // For now, simulate a successful token fetch for testing client logic.
      // In real implementation, replace this with actual HTTP call.
      // IMPORTANT: THIS IS A MOCK AND WILL NOT ACTUALLY AUTHENTICATE.
      // IT WILL LIKELY FAIL AT signInWithCustomToken IF THE TOKEN IS INVALID/MOCKED.
      if (deviceGuestUid.isEmpty) { // Simple check to avoid using empty string if something went wrong
         throw FirebaseAuthException(code: 'NO_DEVICE_GUEST_UID', message: 'Device Guest UID is empty');
      }
      // THIS IS A PLACEHOLDER. A REAL CUSTOM TOKEN IS NEEDED FROM YOUR FUNCTION.
      // Using deviceGuestUid as a fake token will cause signInWithCustomToken to fail.
      // const String MOCK_FAILURE_TOKEN = "THIS_IS_NOT_A_REAL_TOKEN";
      // For testing purposes where function doesn't exist yet, this will throw immediately:
      throw FirebaseAuthException(
          code: 'FUNCTION_NOT_IMPLEMENTED',
          message: 'Firebase Function for custom token not implemented. Cannot sign in.'
      );

      //   final userCredential = await FirebaseAuth.instance.signInWithCustomToken(MOCK_FAILURE_TOKEN /* customToken */);
      //   logger.i("Successfully signed in with custom token for UID: ${userCredential.user?.uid}");

      //   // Update local state (similar to other sign-in methods)
      //   final firebaseUser = userCredential.user;
      //   if (firebaseUser != null) {
      //     final triviaUser = await UserDataSource.getUserById(firebaseUser.uid);
      //     state = state.copyWith(
      //       firebaseUser: firebaseUser,
      //       currentUser: triviaUser ?? TriviaUser.fromFirebaseUser(firebaseUser),
      //       loginNewDayInARow: null, // Or determine based on last login
      //     );
      //   }
      //   return userCredential;
      // } else {
      //   throw Exception('Failed to get custom token from function: ${response.statusCode} ${response.body}');
      // }

    } on FirebaseAuthException catch (e) {
      logger.e("FirebaseAuthException in signInWithDeviceGuestUid: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      logger.e("Error in signInWithDeviceGuestUid: $e");
      rethrow;
    }
  }

  Future<void> linkEmailAndPassword(String email, String password) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || !currentUser.isAnonymous) {
      throw Exception("User must be signed in anonymously to link account.");
    }

    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      await UserDataSource.linkAnonymousAccount(credential);

      // After linking, the user is no longer anonymous.
      // authStateChanges should pick this up. We can force a refresh of user data.
      // Re-initializing user to get updated data (isAnonymous=false, email, etc.)
      await initializeUser();

      // It's also good practice to ensure the newUserRegistrationProvider is cleared
      // as the user is now fully registered.
      ref.read(newUserRegistrationProvider.notifier).clearNewUser();

      // Clear the device_guest_uid from shared_preferences as the account is now permanent
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('device_guest_uid');
      logger.i("Cleared device_guest_uid after account linking.");

    } catch (e) {
      logger.e("Error linking email and password: $e");
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
        logger.i(
            "Warning: currentUserId is empty during deleteUser for firebaseUser: ${firebaseUser.uid}. Using firebaseUser.uid for data deletion.");
        await UserDataSource.clearUser(firebaseUser.uid);
        await UserStatisticsDataSource.clearUserStatistics(firebaseUser.uid);
      } else {
        await UserDataSource.clearUser(currentUserId);
        await UserStatisticsDataSource.clearUserStatistics(currentUserId);
      }

      // 3. Sign out
      final wasGoogleSignIn = isGoogleSignIn(); // Check before firebaseUser becomes null
      final bool wasAnonymous = firebaseUser.isAnonymous; // Check if user was anonymous
      final String? deviceGuestUidForDeletedUser = firebaseUser.uid; // Get UID before signout

      await FirebaseAuth.instance.signOut();
      if (wasGoogleSignIn) {
        await GoogleSignIn().signOut();
      }

      // If the deleted user was the one whose UID is stored as the device_guest_uid,
      // then we should clear device_guest_uid, as that specific guest identity is now gone.
      // This allows a new guest to be created on next "Play as Guest" attempt.
      if (wasAnonymous) { // Or a more specific check if this UID was THE device_guest_uid
        final prefs = await SharedPreferences.getInstance();
        final storedDeviceGuestUid = prefs.getString('device_guest_uid');
        if (storedDeviceGuestUid == deviceGuestUidForDeletedUser) {
          await prefs.remove('device_guest_uid');
          logger.i("Cleared device_guest_uid because the deleted user was the device guest.");
        }
      }

      // 4. Update local state
      state = state.copyWith(
        firebaseUser: null,
        currentUser: TriviaUser.createDefault(uid: "", name: "Guest"),
        loginNewDayInARow: null,
      );
      logger.i("User account deleted and signed out successfully.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (isRetryAfterReauthentication) {
          logger.e(
              "Delete user error: Still requires recent login even after re-authentication attempt. Aborting.");
          throw Exception(
              "Failed to delete account. Please try logging out and in again.");
        } else {
          logger.e(
              "Delete user error: Requires recent login. Prompting for re-authentication.");
          rethrow;
        }
      } else {
        logger.e(
            'Firebase Auth error during user deletion: ${e.code} - ${e.message}');
        rethrow;
      }
    } catch (e) {
      logger.e('Error deleting user account: $e');
      // Attempt to sign out locally if something went wrong mid-process
      if (FirebaseAuth.instance.currentUser != null) {
        try {
          await FirebaseAuth.instance.signOut();
          if (isGoogleSignIn()) await GoogleSignIn().signOut();
        } catch (signOutError) {
          logger.e("Error during fallback sign out: $signOutError");
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
