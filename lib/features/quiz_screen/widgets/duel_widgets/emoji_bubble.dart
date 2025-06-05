import 'package:flutter/material.dart';
import 'package:trivia/core/utils/enums/selected_emoji.dart';
import 'package:trivia/core/utils/size_config.dart'; // Added import

class EmojiBubble extends StatelessWidget {
  final Function(SelectedEmoji) onEmojiSelected;

  const EmojiBubble({
    Key? key,
    required this.onEmojiSelected,
  }) : super(key: key);

  // Using SelectedEmoji enum directly
  // static const List<String> _emojis = ['😀', '😅', '😂', '😈']; // Removed

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // Initialize SizeConfig
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: calcWidth(16.0),
        vertical: calcHeight(8.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(calcWidth(20.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: calcWidth(1.5), // Adjusted for subtle scaling
            blurRadius: calcWidth(3),   // Adjusted for subtle scaling
            offset: Offset(0, calcHeight(2)), // Adjusted for subtle scaling
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // To make the bubble wrap content
        children: SelectedEmoji.values.map((SelectedEmoji emoji) {
          return GestureDetector(
            onTap: () => onEmojiSelected(emoji),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: calcWidth(8.0)),
              child: Text(
                emoji.character, // Use getter from extension
                style: TextStyle(fontSize: calcHeight(24.0)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
