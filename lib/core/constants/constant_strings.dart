class Strings {
  // Assets
  static const String loadingAnimation =
      "assets/animations/loading_animation.json";
  static const String trophyAnimation =
      "assets/animations/trophy_animation.json";
  static const String noInternetAnimation =
      "assets/animations/no_internet_animation.json";
  static const String countDownAnimation =
      "assets/animations/count_down_animation.json";
  static const String underConstructionAnimation =
      "assets/animations/under_construction.json";

  static const String appBarDrop = "assets/drop.svg";
  static const String closeChestIcon = "assets/icons/close_chest_icon.svg";
  static const String openChestIcon = "assets/icons/open_chest_icon.svg";
  static const String emptyChestIcon = "assets/icons/empty_chest_icon.svg";
  static const String energyIcon = "assets/icons/energy_icon.svg";
  static const String coinsIcon = "assets/icons/coins_icon.svg";
  static const String singleCoinsIcon = "assets/icons/coin_single_icon.svg";
  static const String coinsTossIcon = "assets/icons/coin_toss_icon.svg";
  static const String coinsHeapIcon = "assets/icons/coins_heap_icon.svg";
  static const String authBackground = "assets/blob-scene-haikei.svg";
  static const String wheelOfFortune = "assets/wheel_of_fortune.svg";
  static const String botAvatar1 = "assets/bots_avatars/bot_avatar_1.svg";
  static const String botAvatar2 = "assets/bots_avatars/bot_avatar_2.svg";
  static const String botAvatar3 = "assets/bots_avatars/bot_avatar_3.svg";
  static const String botAvatar4 = "assets/bots_avatars/bot_avatar_4.svg";
  static const String botAvatar5 = "assets/bots_avatars/bot_avatar_5.svg";
  static const String botAvatar6 = "assets/bots_avatars/bot_avatar_6.svg";

  // Shared Preferences
  static const String originalUserImagePathKey = "original_user_image_path";

  // Hero Tag
  static const String userAvatarTag = "userAvatar";

  // Common Strings
  static const String error = "Error:";
  static const String loading = "Loading...:";
  static const String email = "Email";
  static const String password = "Password";
  static const String returnHome = "Return to Home";
  static const String cancel = "Cancel";
  static const String no = "No";
  static const String guest = "Guest";

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
  static const String deleteAccount = 'Delete Account';
  static const String userNameNotAllowed = 'User name not allowed.';
  static const String onlyEnglishLettersAllowed =
      'Only English letters and numbers are allowed.';
  static const String userNameTooLong = 'User name is too long (max';
  static const String characters = 'characters).';

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
  static const String waitingPlayersJoin = 'Waiting for all players to join...';
  static const String score = 'Score:';

  // Top Players
  static const String noPlayersFound = "No players found";
  static const String viewAll = "View all";
  static const String playersSmall = "players";
  static const String showLess = "Show less";
  static const String unknownPlayer = "Unknown Player";
  static const String pts = "pts";

  // Result Screen
  static const String correctAnswers = 'Correct Answers';
  static const String wrongAnswers = 'Wrong Answers';
  static const String didntAnswer = 'Didn\'t Answer';
  static const String averageTime = 'Average Time';
  static const String totalScore = 'Total Score';
  static const String topPlayers = 'Top Players';

  // Question Review
  static const String correctExclamationMark = 'Correct!';
  static const String timesUp = 'Time\'s up!';
  static const String incorrect = 'Incorrect!';
  static const String correctAnswer = 'Correct Answer:';
  static const String nextQuestionIn3s = 'Next question in 3s';

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
  static const String passwordMustContainLetter =
      "Password must contain at least one English letter";
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
  static const String playAsGuest = "Play as Guest";

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
  static const String duelChallenge = 'Duel Challenge';
  static const String waitingForMorePlayers = 'Waiting for more players...';
  static const String filterRooms = 'Filter Rooms';
  static const String errorLoadingCategories = 'Error loading categories';
  static const String category = 'Category';
  static const String numberOfQuestions = 'Number of Questions';
  static const String any = 'Any';
  static const String clear = 'Clear';
  static const String setFilters = 'Set Filters';
  static const String selectDifficulty = 'Select Difficulty:';

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
  static const String watchAd = '(Watch Ad)';

  // Trophy Dialog
  static const String newText = 'New';
  static const String trophyUnlocked = 'Trophy Unlocked';
  static const String goToProfile = 'GO TO PROFILE';
  static const String keepUpUnlockMore =
      'Keep up the good work to unlock more trophies!';

  // Resource Dialog
  static const String yourTreasureChest = 'Your Treasure Chest!';
  static const String energy = 'Energy';
  static const String gold = 'Gold';
  static const String tapViewDetails = 'Tap to view details';
  static const String closeTreasureChest = 'Close Treasure Chest';

  // Daily Dialog
  static const String dailyLoginRewards = 'Daily Login Rewards';
  static const String day = 'Day';
  static const String claim = 'CLAIM';
  static const String keepLogin = 'Keep login every day to get the rewards';
  static const String youClaimedAll = "You've claimed all rewards!";
  static const String claimYourRewards =
      "Claim your rewards by logging in daily!";

  // Duel Result
  static const String duelResults = "Duel Results";
  static const String itsDraw = "It's a Draw!";
  static const String youWin = "You Win!";
  static const String youLost = "You Lost!";
  static const String you = "You";
  static const String opponent = "Opponent";
  static const String vs = "VS";
  static const String statisticsNotAvailable = "Statistics are not available";
  static const String gamePerformance = "Game Performance";
  static const String avgResponseTime = "Avg. Response Time";
  static const String finalScore = "Final Score";
  static const String playAgain = "Play Again";

  // Game Cancel
  static const String gameCanceled = "Game Canceled";
  static const String yourOpponentLeftGame = "Your opponent left the game";
  static const String youLeftGame = "You left the game";
  static const String youWinAutomatically = "You win automatically!";
  static const String youLoseAutomatically = "You lose automatically.";

  // Under Construction
  static const String gotIt = "Got It";
  static const String thisFeatureComingSoon =
      "This feature is coming soon!\nStay tuned for updates.";
  static const String underConstruction = "Under Construction";

  // Delete User Account Dialog
  static const String accountDeletedSuccessfully =
      "Account deleted successfully.";
  static const String needToReAuthenticate =
      "This action requires recent authentication. Please provide your credentials below.";
  static const String incorrectPassword =
      "Incorrect password. Please try again.";
  static const String reAuthenticateToDelete = "Re-authenticate to Delete";
  static const String deleteAccountQ = "Delete Account?";
  static const String sureDeleteAccountQ =
      "Are you sure you want to delete your account? This action is irreversible and will delete all your data.";
  static const String reAuthenticateWithGoogle = "Re-authenticate with Google";
  static const String confirmDelete = "Confirm Delete";
  static const String yesDelete = "Yes, Delete";

  // Insufficient Coins
  static const String insufficientCoins = "Insufficient Coins";
  static const String youNeed = "You need";
  static const String coinsToPlayGame = "coins to play this game";
  static const String currentColon = "Current:";

  // Link Account Section (Profile Screen)
  static const String saveYourProgress = "Save Your Progress!";
  static const String createAccountToSaveStats =
      "Create an account to save your statistics and achievements.";
  static const String saveAccount = "Save Account";

  // Guest Logout Warning Dialog strings
  static const String warningTitle = 'Warning!';
  static const String guestLogoutWarning =
      'You are currently using a guest account. If you logout, all your progress will be permanently lost!';
  static const String saveProgressTip =
      'Tip: Create an account with email and password to save your progress!';
  static const String logoutAnyway = 'Logout Anyway';
}
