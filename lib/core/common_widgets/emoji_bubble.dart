import 'package:flutter/material.dart';
import 'package:Quizdom/core/utils/enums/selected_emoji.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class EmojiBubble extends StatelessWidget {
  final Function(SelectedEmoji) onEmojiSelected;

  const EmojiBubble({
    super.key,
    required this.onEmojiSelected,
  });

  // Using SelectedEmoji enum directly
  // static const List<String> _emojis = ['😀', '😅', '😂', '😈']; // Removed

  @override
  Widget build(BuildContext context) {
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
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: calcWidth(1.5),
            blurRadius: calcWidth(3),
            offset: Offset(0, calcHeight(2)),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: SelectedEmoji.values.map((SelectedEmoji emoji) {
          return GestureDetector(
            onTap: () => onEmojiSelected(emoji),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: calcWidth(8.0)),
              child: Text(
                emoji.character,
                style: TextStyle(fontSize: calcHeight(24.0)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
