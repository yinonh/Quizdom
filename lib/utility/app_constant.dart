import 'package:flutter/material.dart';

class AppConstant {
  static const String primaryColor = "#007F73";
  static const String secondaryColor = "#4CCD99";
  static const String onPrimary = "#FFC700";
  static const String highlightColor = "#FFF455";

  static const Map<int, IconData> categoryIcons = {
    9: Icons.public, // General Knowledge
    10: Icons.book, // Entertainment: Books
    11: Icons.movie, // Entertainment: Film
    12: Icons.music_note, // Entertainment: Music
    13: Icons.theater_comedy, // Entertainment: Musicals & Theatres
    14: Icons.tv, // Entertainment: Television
    15: Icons.videogame_asset, // Entertainment: Video Games
    16: Icons.games, // Entertainment: Board Games
    17: Icons.nature, // Science & Nature
    18: Icons.computer, // Science: Computers
    19: Icons.calculate, // Science: Mathematics
    20: Icons.local_library, // Mythology
    21: Icons.sports, // Sports
    22: Icons.map, // Geography
    23: Icons.history_edu, // History
    24: Icons.gavel, // Politics
    25: Icons.brush, // Art
    26: Icons.star, // Celebrities
    27: Icons.pets, // Animals
    28: Icons.directions_car, // Vehicles
    29: Icons.auto_stories, // Entertainment: Comics
    30: Icons.devices, // Science: Gadgets
    31: Icons.menu_book, // Entertainment: Japanese Anime & Manga
    32: Icons.animation, // Entertainment: Cartoon & Animations
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
    23: Colors.yellow,
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
