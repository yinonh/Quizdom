import 'package:flutter/material.dart';
import 'package:trivia/core/utils/enums/level_enum.dart';
import 'package:trivia/core/utils/enums/trophy_type.dart';

class AppConstant {
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

  // Game Settings
  static const int questionTime = 10;
  static const int numberOfQuestions = 10;
  static const List<String> difficultyMap = ["easy", "medium", "hard"];
  static const String questionsDifficulty = "medium";
  static const int topUsersLength = 10;
  static const List<int> loginAwards = [0, 10, 35, 50, 100, 200];

  static const Map<int, IconData> categoryIcons = {
    9: Icons.public_rounded, // General Knowledge
    10: Icons.book_rounded, // Entertainment: Books
    11: Icons.movie_rounded, // Entertainment: Film
    12: Icons.music_note_rounded, // Entertainment: Music
    13: Icons.theater_comedy_rounded, // Entertainment: Musicals & Theatres
    14: Icons.tv_rounded, // Entertainment: Television
    15: Icons.videogame_asset_rounded, // Entertainment: Video Games
    16: Icons.games_rounded, // Entertainment: Board Games
    17: Icons.nature_rounded, // Science & Nature
    18: Icons.computer_rounded, // Science: Computers
    19: Icons.calculate_rounded, // Science: Mathematics
    20: Icons.local_library_rounded, // Mythology
    21: Icons.sports_rounded, // Sports
    22: Icons.map_rounded, // Geography
    23: Icons.history_edu_rounded, // History
    24: Icons.gavel_rounded, // Politics
    25: Icons.brush_rounded, // Art
    26: Icons.star_rounded, // Celebrities
    27: Icons.pets_rounded, // Animals
    28: Icons.directions_car_rounded, // Vehicles
    29: Icons.auto_stories_rounded, // Entertainment: Comics
    30: Icons.devices_rounded, // Science: Gadgets
    31: Icons.menu_book_rounded, // Entertainment: Japanese Anime & Manga
    32: Icons.animation_rounded, // Entertainment: Cartoon & Animations
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
