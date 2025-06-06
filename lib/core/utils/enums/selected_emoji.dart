enum SelectedEmoji {
  happy, // 😀
  sweatGrin, // 😅
  laughing, // 😂
  devil // 😈
}

extension SelectedEmojiExtension on SelectedEmoji {
  String get character {
    switch (this) {
      case SelectedEmoji.happy:
        return '😀';
      case SelectedEmoji.sweatGrin:
        return '😅';
      case SelectedEmoji.laughing:
        return '😂';
      case SelectedEmoji.devil:
        return '😈';
    }
  }

  // Helper for JSON serialization if storing by name
  static SelectedEmoji fromName(String name) {
    return SelectedEmoji.values.firstWhere((e) => e.name == name,
        orElse: () =>
            SelectedEmoji.happy); // Default to happy if name not found
  }
}
