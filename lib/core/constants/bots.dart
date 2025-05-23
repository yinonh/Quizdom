import 'dart:math';

import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/models/user_statistics.dart';

import 'app_constant.dart';
import 'constant_strings.dart';

/// A simple bot service that creates and manages bot users for trivia games
class BotService {
  // Singleton pattern
  static final BotService _instance = BotService._internal();
  factory BotService() => _instance;
  BotService._internal();

  // Random generator
  final _random = Random();

  // Currently selected bot
  static TriviaBot? currentBot;

  // Available bot avatars
  final List<String> _botAvatars = [
    Strings.botAvatar1,
    Strings.botAvatar2,
    Strings.botAvatar3,
    Strings.botAvatar4,
    Strings.botAvatar5,
    Strings.botAvatar6,
  ];

  /// Set a new bot as the current bot
  void setCurrentBot(TriviaBot bot) {
    currentBot = bot;
  }

  /// Create a random bot with optional custom properties
  TriviaBot createRandomBot(
      {String? name, String? imageUrl, double? accuracy}) {
    final botAccuracy = accuracy ??
        (0.3 + _random.nextDouble() * 0.4); // Random accuracy between 0.3-0.7

    // Create TriviaUser for the bot
    final user = TriviaUser(
      uid: AppConstant.botUserId,
      name: name ?? _generateRandomBotName(),
      userXp: _random.nextDouble() * 2000,
      recentTriviaCategories: [],
      imageUrl: imageUrl ?? _botAvatars[_random.nextInt(_botAvatars.length)],
    );

    // Create and return the bot
    return TriviaBot(
      id: AppConstant.botUserId,
      user: user,
      accuracy: botAccuracy,
    );
  }

  /// Create a random bot and set it as the current bot
  TriviaBot createAndSetRandomBot({double? accuracy}) {
    final bot = createRandomBot(accuracy: accuracy);
    setCurrentBot(bot);
    return bot;
  }

  /// Generate random bot name
  String _generateRandomBotName() {
    final prefixes = ["Bot", "AI", "Robo", "Virtual"];
    final suffixes = ["Player", "Challenger", "Competitor", "Genius"];

    return "${prefixes[_random.nextInt(prefixes.length)]} ${suffixes[_random.nextInt(suffixes.length)]}";
  }
}

/// A simple bot class that includes a TriviaUser, accuracy, and generated statistics
class TriviaBot {
  final String id;
  final TriviaUser user;
  final double accuracy;
  late final UserStatistics _statistics;

  TriviaBot({
    required this.id,
    required this.user,
    required this.accuracy,
  }) {
    // Generate statistics once during initialization
    _statistics = _generateStatistics();
  }

  /// Get the pre-generated statistics
  UserStatistics get statistics => _statistics;

  /// Generate statistics based on the bot's accuracy (called only once during initialization)
  UserStatistics _generateStatistics() {
    final random = Random(id.hashCode); // Use seeded random for consistency

    // Base game stats
    final totalGamesPlayed = 10 + random.nextInt(50);
    final totalQuestions =
        totalGamesPlayed * 10; // Assume 10 questions per game

    // Calculate answers based on exact accuracy
    final correctAnswers = (totalQuestions * accuracy).round();

    // For the remaining questions, split them deterministically
    final remainingQuestions = totalQuestions - correctAnswers;

    // Use a fixed ratio for unanswered vs wrong (e.g., 20% unanswered, 80% wrong)
    // Or you could make this completely deterministic
    final unansweredQuestions = (remainingQuestions * 0.2).round();
    final wrongAnswers = remainingQuestions - unansweredQuestions;

    // Calculate win/loss based on accuracy
    final gamesWon = (totalGamesPlayed * accuracy).round();
    final gamesLost = totalGamesPlayed - gamesWon;

    return UserStatistics(
      totalGamesPlayed: totalGamesPlayed,
      totalCorrectAnswers: correctAnswers,
      totalWrongAnswers: wrongAnswers,
      totalUnanswered: unansweredQuestions,
      avgAnswerTime: 2.0 + random.nextDouble() * 8.0, // 2-10 seconds
      gamesPlayedAgainstPlayers: (totalGamesPlayed * 0.7).round(),
      gamesWon: gamesWon,
      gamesLost: gamesLost,
      totalScore: correctAnswers * 10, // 10 points per correct answer
      currentLoginStreak: 1 + random.nextInt(5),
      longestLoginStreak: 5 + random.nextInt(10),
    );
  }
}
