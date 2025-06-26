import 'package:flutter/material.dart';
import 'package:Quizdom/core/utils/enums/level.dart';
import 'package:Quizdom/core/utils/enums/trophy_type.dart';
import 'package:Quizdom/data/models/user_statistics.dart';

class AppConstant {
  // App colors
  static const Color primaryColor = Color(0xFF00AFFF);
  static const Color secondaryColor = Color(0xFF82D3C8);
  static const Color onPrimaryColor = Color(0xFFFF9000);
  static const Color highlightColor = Color(0xFFC357CB);
  static const Color softHighlightColor = Color(0xFFEDCAEB);
  static const Color goldColor = Color(0xFFFFD700);

  // Trophy Colors
  static const Color darkGoldColor = Color(0xFFFFB627);
  static const Color silverColor = Color(0xFF5C6B73);
  static const Color bronzeColor = Color(0xFFB87333);
  static const Color platinumColor = Color(0xFF2E294E);
  static const Color diamondColor = Color(0xFF00B4D8);
  static const Color rubyColor = Color(0xFFD81159);
  static const Color defaultColor = Color(0xFFD1D1D1);

  // Elements Colors
  static const Color lightGray = Color(0xFFD1D1D1);
  static const Color gray = Color(0xFF9E9E9E);
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFF44336);
  static const Color amber = Colors.amber;
  static const Color lightBlue = Color(0xFFBBDEFB);
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // Game Settings
  static const int questionTime = 10;
  static const int numberOfQuestions = 10;
  static const List<String> difficultyMap = ["easy", "medium", "hard"];
  static const String questionsDifficulty = "medium";
  static const int topUsersLength = 10;
  static const List<int> loginAwards = [0, 10, 35, 50, 100, 200];
  static const matchTimeout = 20;
  static const String botUserId = "-1";

  static const Map<int, String> categoryIcons = {
    -1: "assets/icons/all_icon.svg", // General Knowledge
    9: "assets/icons/general_knowledge_icon.svg", // General Knowledge
    10: "assets/icons/books_icon.svg", // Entertainment: Books
    11: "assets/icons/movies_icon.svg", // Entertainment: Film
    12: "assets/icons/music_icon.svg", // Entertainment: Music
    13: "assets/icons/musical_icon.svg", // Entertainment: Musicals & Theatres
    14: "assets/icons/tv_icon.svg", // Entertainment: Television
    15: "assets/icons/video_games_icon.svg", // Entertainment: Video Games
    16: "assets/icons/board_games_icon.svg", // Entertainment: Board Games
    17: "assets/icons/science_icon.svg", // Science & Nature
    18: "assets/icons/computers_icon.svg", // Science: Computers
    19: "assets/icons/mathematics_icon.svg", // Science: Mathematics
    20: "assets/icons/mythology_icon.svg", // Mythology
    21: "assets/icons/sports_icon.svg", // Sports
    22: "assets/icons/geography_icon.svg", // Geography
    23: "assets/icons/history_icon.svg", // History
    24: "assets/icons/politics_icon.svg", // Politics
    25: "assets/icons/art_icon.svg", // Art
    26: "assets/icons/celebrities_icon.svg", // Celebrities
    27: "assets/icons/animals_icon.svg", // Animals
    28: "assets/icons/cars_icon.svg", // Vehicles
    29: "assets/icons/comics_icon.svg", // Entertainment: Comics
    30: "assets/icons/gadgets_icon.svg", // Science: Gadgets
    31: "assets/icons/anime_icon.svg", // Entertainment: Japanese Anime & Manga
    32: "assets/icons/cartoon_icon.svg", // Entertainment: Cartoon & Animations
  };

  static const Map<int, Color> categoryColors = {
    9: Colors.red,
    10: Colors.amber,
    11: Colors.purple,
    12: Colors.teal,
    13: Colors.orange,
    14: Colors.pinkAccent,
    15: Colors.blue,
    16: Colors.brown,
    17: Colors.blueGrey,
    18: Colors.green,
    19: Colors.greenAccent,
    20: Colors.deepPurpleAccent,
    21: Colors.lightGreen,
    22: Colors.grey,
    23: Colors.red,
    24: Colors.deepOrangeAccent,
    25: Colors.indigo,
    26: Colors.lightBlueAccent,
    27: Colors.indigoAccent,
    28: Colors.black,
    29: Colors.pink,
    30: Colors.greenAccent,
    31: Colors.orange,
    32: Colors.amber,
  };

  static const loginStreakThresholds = {
    Level.bronze: 3,
    Level.silver: 7,
    Level.gold: 14,
    Level.platinum: 30,
    Level.diamond: 60,
    Level.ruby: 90,
  };

  static const gamesPlayedThresholds = {
    Level.bronze: 10,
    Level.silver: 50,
    Level.gold: 100,
    Level.platinum: 200,
    Level.diamond: 500,
    Level.ruby: 1000,
  };

  static const gamesWonThresholds = {
    Level.bronze: 5,
    Level.silver: 25,
    Level.gold: 50,
    Level.platinum: 100,
    Level.diamond: 250,
    Level.ruby: 500,
  };

  static const totalScoreThresholds = {
    Level.bronze: 1000,
    Level.silver: 5000,
    Level.gold: 10000,
    Level.platinum: 25000,
    Level.diamond: 50000,
    Level.ruby: 100000,
  };

  // Get trophy level based on thresholds and value
  static Level getTrophyLevel(Map<Level, int> thresholds, int value) {
    if (value >= thresholds[Level.ruby]!) return Level.ruby;
    if (value >= thresholds[Level.diamond]!) return Level.diamond;
    if (value >= thresholds[Level.platinum]!) return Level.platinum;
    if (value >= thresholds[Level.gold]!) return Level.gold;
    if (value >= thresholds[Level.silver]!) return Level.silver;
    if (value >= thresholds[Level.bronze]!) return Level.bronze;
    return Level.none;
  }

  static IconData getTrophyIcon(TrophyType category) {
    switch (category) {
      case TrophyType.login:
        return Icons.calendar_today_rounded;
      case TrophyType.games:
        return Icons.sports_esports_rounded;
      case TrophyType.wins:
        return Icons.emoji_events_rounded;
      case TrophyType.score:
        return Icons.check_circle_rounded;
      case TrophyType.points:
        return Icons.stars_rounded;
    }
  }
}

// Create a Trophy Achievement model
class TrophyAchievement {
  final TrophyType type;
  final Level level;
  final int value;
  final int threshold;

  TrophyAchievement({
    required this.type,
    required this.level,
    required this.value,
    required this.threshold,
  });

  String get typeLabel {
    switch (type) {
      case TrophyType.login:
        return 'Login Streak';
      case TrophyType.games:
        return 'Games Played';
      case TrophyType.wins:
        return 'Games Won';
      case TrophyType.score:
        return 'Total Score';
      case TrophyType.points:
        return 'Points';
    }
  }

  Color get levelColor {
    switch (level) {
      case Level.bronze:
        return AppConstant.bronzeColor;
      case Level.silver:
        return AppConstant.silverColor;
      case Level.gold:
        return AppConstant.goldColor;
      case Level.platinum:
        return AppConstant.platinumColor;
      case Level.diamond:
        return AppConstant.diamondColor;
      case Level.ruby:
        return AppConstant.rubyColor;
      default:
        return AppConstant.defaultColor;
    }
  }
}

// Trophy Achievement Service
class TrophyAchievementService {
  // Check for new achievements
  static List<TrophyAchievement> checkNewAchievements(
      UserStatistics oldStats, UserStatistics newStats) {
    List<TrophyAchievement> newAchievements = [];

    // Check login streak trophy
    Level oldLoginLevel = AppConstant.getTrophyLevel(
        AppConstant.loginStreakThresholds, oldStats.longestLoginStreak);
    Level newLoginLevel = AppConstant.getTrophyLevel(
        AppConstant.loginStreakThresholds, newStats.longestLoginStreak);
    if (newLoginLevel.index > oldLoginLevel.index &&
        !_hasTrophyBeenDisplayed(newStats, 'login', newLoginLevel)) {
      newAchievements.add(
        TrophyAchievement(
          type: TrophyType.login,
          level: newLoginLevel,
          value: newStats.currentLoginStreak,
          threshold: AppConstant.loginStreakThresholds[newLoginLevel]!,
        ),
      );
    }

    // Check games played trophy
    Level oldGamesLevel = AppConstant.getTrophyLevel(
        AppConstant.gamesPlayedThresholds, oldStats.totalGamesPlayed);
    Level newGamesLevel = AppConstant.getTrophyLevel(
        AppConstant.gamesPlayedThresholds, newStats.totalGamesPlayed);
    if (newGamesLevel.index > oldGamesLevel.index &&
        !_hasTrophyBeenDisplayed(newStats, 'games', newGamesLevel)) {
      newAchievements.add(
        TrophyAchievement(
          type: TrophyType.games,
          level: newGamesLevel,
          value: newStats.totalGamesPlayed,
          threshold: AppConstant.gamesPlayedThresholds[newGamesLevel]!,
        ),
      );
    }

    // Check games won trophy
    Level oldWinsLevel = AppConstant.getTrophyLevel(
        AppConstant.gamesWonThresholds, oldStats.gamesWon);
    Level newWinsLevel = AppConstant.getTrophyLevel(
        AppConstant.gamesWonThresholds, newStats.gamesWon);
    if (newWinsLevel.index > oldWinsLevel.index &&
        !_hasTrophyBeenDisplayed(newStats, 'wins', newWinsLevel)) {
      newAchievements.add(
        TrophyAchievement(
          type: TrophyType.wins,
          level: newWinsLevel,
          value: newStats.gamesWon,
          threshold: AppConstant.gamesWonThresholds[newWinsLevel]!,
        ),
      );
    }

    // Check total score trophy
    Level oldScoreLevel = AppConstant.getTrophyLevel(
        AppConstant.totalScoreThresholds, oldStats.totalScore);
    Level newScoreLevel = AppConstant.getTrophyLevel(
        AppConstant.totalScoreThresholds, newStats.totalScore);
    if (newScoreLevel.index > oldScoreLevel.index &&
        !_hasTrophyBeenDisplayed(newStats, 'score', newScoreLevel)) {
      newAchievements.add(
        TrophyAchievement(
          type: TrophyType.score,
          level: newScoreLevel,
          value: newStats.totalScore,
          threshold: AppConstant.totalScoreThresholds[newScoreLevel]!,
        ),
      );
    }

    return newAchievements;
  }

  // Helper to check if a trophy has been displayed
  static bool _hasTrophyBeenDisplayed(
      UserStatistics stats, String typeKey, Level level) {
    if (!stats.displayedTrophies.containsKey(typeKey)) {
      return false;
    }
    return stats.displayedTrophies[typeKey]!
        .contains(level.toString().split('.').last);
  }

  // Update displayed trophies map
  static Map<String, List<String>> updateDisplayedTrophies(
      UserStatistics stats, List<TrophyAchievement> achievements) {
    Map<String, List<String>> updatedTrophies =
        Map.from(stats.displayedTrophies);

    for (var achievement in achievements) {
      String typeKey = achievement.type.toString().split('.').last;
      String levelValue = achievement.level.toString().split('.').last;

      if (!updatedTrophies.containsKey(typeKey)) {
        updatedTrophies[typeKey] = [];
      }

      if (!updatedTrophies[typeKey]!.contains(levelValue)) {
        updatedTrophies[typeKey] = [...updatedTrophies[typeKey]!, levelValue];
      }
    }

    return updatedTrophies;
  }
}
