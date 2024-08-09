import 'package:flutter/material.dart';

class AppConstant {
  static const String primaryColor = "#00afff";
  static const String secondaryColor = "#82d3c8";
  static const String onPrimary = "#ff9000";
  static const String highlightColor = "#c357cb";
  static const String userAvatarBackground = "#edcaeb";

  static const int questionTime = 10;

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
}
