extension DateTimeExtensions on DateTime {
  bool get isYesterday {
    final now = DateTime.now();

    // Get the DateTime for yesterday at midnight.
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));

    // Get the DateTime for today at midnight.
    final today = DateTime(now.year, now.month, now.day);

    // Check if the current DateTime is between yesterday's midnight and today's midnight.
    return isAfter(yesterday) && isBefore(today);
  }

  bool get isOlderThanYesterday {
    final now = DateTime.now();

    // Get the DateTime for yesterday at midnight.
    final yesterdayMidnight = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));

    // Return true if the date is strictly before yesterday's midnight.
    return isBefore(yesterdayMidnight);
  }
}
