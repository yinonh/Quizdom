class Strings {
  // Assets
  static const String loadingAnimation = "assets/loading_animation.json";
  static const String noInternetAnimation = "assets/no_internet.json";
  static const String appBarDrop = "assets/drop.svg";
  static const String coinsIcon = "assets/icons/coins_icon.svg";
  static const String authBackground = "assets/blob-scene-haikei.svg";
  static const String wheelOfFortune = "assets/wheel_of_fortune.png";

  // Shared Preferences
  static const String originalUserImagePathKey = "original_user_image_path";

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

  //No Internet Screen
  static const String noInternet = 'No Internet';
  static const String pleaseCheckInternetAndTryAgain =
      'Please check your internet connection and try again.';
  static const String retryConnection = 'Retry Connection';

  //Achievements Section
  static const String moreTo = 'more to';
  static const String maxLevelAchieved = 'Max level achieved!';
  static const String achievements = 'Achievements';
  static const String dailyStreak = 'Daily Streak';
  static const String games = 'games';
  static const String victories = 'Victories';
  static const String wins = 'wins';
  static const String points = 'points';

  // Statistics Section
  static const String statisticsNotAvailableYet =
      'Statistics Not Available Yet';
  static const String answerDistribution = 'Answer Distribution';
  static const String correct = 'Correct';
  static const String wrong = 'Wrong';
  static const String skipped = 'Skipped';
  static const String accuracyRate = 'Accuracy Rate:';
  static const String gamesPlayed = 'Games Played';
  static const String loginStreak = 'Login Streak';
  static const String current = 'Current';
  static const String best = 'Best';
  static const String gameModes = 'Game Modes';
  static const String singlePlayer = 'Single Player';
  static const String timePerformance = 'Time Performance';
  static const String averageResponseTime = 'Average Response Time';
  static const String perquestion = 'per question';
  static const String averageGameDuration = 'Average Game Duration';
  static const String pergame = 'per game';
  static const String lightningFast = 'Lightning Fast! ⚡';
  static const String quickThinker = 'Quick Thinker 🏃';
  static const String steadyPace = 'Steady Pace 👍';
  static const String takingTime = 'Taking Time 🤔';

  // Quiz Screen
  static const String question = 'Question';

  // Result Screen
  static const String correctAnswers = 'Correct Answers';
  static const String wrongAnswers = 'Wrong Answers';
  static const String didntAnswer = 'Didn\'t Answer';
  static const String averageTime = 'Average Time';
  static const String totalScore = 'Total Score';
  static const String topPlayers = 'Top Players';

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
  static const String continueWithGoogle = "Continue with Google";

  // Profile Overview Screen
  static const String mysteryPlayer = 'Mystery Player';
  static const String xp = 'XP';
  static const String gameStats = 'Game Stats';
  static const String winRate = 'Win Rate';
  static const String performance = 'Performance';
  static const String accuracy = 'Accuracy';
  static const String avgTime = 'Avg Time';
  static const String close = 'Close';

  // Intro Screen
  static const String back = 'Back';
  static const String start = 'Start';
  static const String ready = 'Ready';
  static const String nextPlayer = 'Next Player';
  static const String soloChallenge = 'Solo Challenge';
  static const String questions = 'Questions:';
  static const String difficulty = 'Difficulty:';
  static const String timePerQuestion = 'Time per Question:';
  static const String price = 'Price:';
  static const String players = 'Players';
  static const String groupChallenge = 'Group Challenge';
  static const String duelMode = 'Duel Mode';
  static const String waitingForMorePlayers = 'Waiting for more players...';
  static const String filterRooms = 'Filter Rooms';
  static const String errorLoadingCategories = 'Error loading categories';
  static const String category = 'Category';
  static const String numberOfQuestions = 'Number of Questions';
  static const String any = 'Any';
  static const String clear = 'Clear';

  // Fortune Wheel Screen
  static const String congratulations = 'Congratulations!';
  static const String youWon = 'You won';
  static const String coinsExclamationMark = 'coins!';
  static const String coins = 'coins';
  static const String awesome = 'Awesome!';
  static const String betterLuckNextTime = 'Better luck next time!';
  static const String keepPlayingWinCoins = 'Keep playing to win coins!';
  static const String spinAndWin = 'Spin & Win!';
  static const String tryYourLuckWinCoins = 'Try your luck to win coins!';
  static const String noPrize = 'No Prize';
  static const String spinning = 'Spinning...';
  static const String spinNow = 'SPIN NOW!';
  static const String tenCoins = '(10 coins)';
}
