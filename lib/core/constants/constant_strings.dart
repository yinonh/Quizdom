class Strings {
  // Assets
  static const String loadingAnimation = "assets/loading_animation.json";
  static const String noInternetAnimation = "assets/no_internet.json";
  static const String appBarDrop = "assets/drop.svg";
  static const String authBackground = "assets/blob-scene-haikei.svg";

  // Shared Preferences
  static const String originalUserImagePathKey = "original_user_image_path";
  static const String croppedUserImagePathKey = "cropped_user_image_path";
  static const String userAvatarKey = "user_avatar";

  // Hero Tag
  static const String userAvatarTag = "userAvatar";

  // Route Names
  static const String authRouteName = "/auth";
  static const String avatarRouteName = "/avatar";
  static const String categoriesRouteName = "/categories_screen";
  static const String profileRouteName = "/profile";
  static const String quizRouteName = "/quiz_screen";
  static const String resultsRouteName = "/results_screen";
  static const String triviaIntroScreen = "/triviaIntroScreen";

  // Common Strings
  static const String error = "Error:";
  static const String email = "Email";
  static const String password = "Password";

  // Custom Drawer
  static const String home = "Home";
  static const String profile = "Profile";
  static const String about = "About";
  static const String logout = "Logout";
  static const String hello = "Hello,";

  // Avatar Screen
  static const String setImage = "Set Image";
  static const String save = "Save";

  static String getCroppedImagePath(String directory, String currentTime) {
    return '$directory/cropped_image_$currentTime.png';
  }

  static String getOriginalImagePath(String directory, String currentTime) {
    return '$directory/original_image_$currentTime.png';
  }

  // Categories Screen
  static const String recentPlayedCategories = "Recent Played Categories";
  static const String createQuiz = "Create Quiz";
  static const String soloMode = "Friendly Duel";
  static const String multiplayer = "Multiplayer";
  static const String featuredCategories = "Featured Categories";

  // Profile Screen
  static const String username = "Username";
  static const String trophies = "Trophies";
  static const String goldTrophy = 'Gold';
  static const String silverTrophy = 'Silver';
  static const String bronzeTrophy = 'Bronze';
  static const String platinumTrophy = 'Platinum';
  static const String diamondTrophy = 'Diamond';
  static const String rubyTrophy = 'Ruby';
  static const String statisticsTitle = 'Statistics';
  static const String correctAnswersText = 'Correct answers in round: ';
  static const String bestTimeText = 'Best time: ';
  static const String bestTotalScoreText = 'Best total score: ';
  static const String currentPassword = 'Current Password';
  static const String currentPasswordRequired = 'Current Password Required';
  static const String newPassword = 'New Password';

  // Quiz Screen
  static const String question = 'Question';

  // Result Screen
  static const String correctAnswers = 'Correct Answers';
  static const String wrongAnswers = 'Wrong Answers';
  static const String didntAnswer = 'Didn\'t Answer';
  static const String averageTime = 'Average Time';

  // Auth Screen
  static const String createAccount = "Create Account";
  static const String welcomeBack = "Welcome Back";
  static const String confirmPassword = "Confirm Password";
  static const String login = "Login";
  static const String signUp = "Sign Up";
  static const String switchToSignUp = "Don't have an account? Sign Up";
  static const String switchToLogin = "Already have an account? Login";
  static const String invalidEmail = "Invalid email";
  static const String passwordTooShort =
      "Password must be at least 6 characters long";
  static const String passwordsNotMatch = "Passwords do not match";
  static const String userDisabled =
      "The user corresponding to the given email has been disabled.";
  static const String userNotFound =
      "There is no user corresponding to the given email.";
  static const String wrongPassword =
      "The password is invalid for the given email.";
  static const String emailAlreadyUse =
      "The email address is already in use by another account.";
  static const String operationNotAllowed =
      "Email/Password accounts are not enabled.";
  static const String passwordTooWeak = "The password is too weak.";
  static const String invalidCredential = "The credential is not valid.";
  static const String accountExistsWithDifferentCredential =
      "Account exists with different credentials.";
  static const String invalidVerificationCode = "Invalid verification code.";
  static const String invalidVerificationID = "Invalid verification ID.";
  static const String sessionCookieExpired = "The session cookie has expired.";
  static const String sessionCookieRevoked =
      "The session cookie has been revoked.";
  static const String tooManyRequests =
      "Too many requests. Please try again later.";
  static const String missingEmail = "An email address must be provided.";
  static const String undefinedError = "An undefined error occurred.";
}
