import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trivia/data/models/user_achievements.dart';

part 'user.freezed.dart';
part 'user.g.dart';

String? fileToJson(File? file) {
  return file?.path;
}

File? fileFromJson(String? path) {
  return path != null ? File(path) : null;
}

@freezed
class TriviaUser with _$TriviaUser {
  const factory TriviaUser({
    String? uid,
    String? name,
    String? email,
    @JsonKey(fromJson: fileFromJson, toJson: fileToJson) File? userImage,
    String? avatar,
    required UserAchievements achievements,
    required DateTime lastLogin,
    required List<int> recentTriviaCategories,
    required List<int> trophies,
    required double userXp,
  }) = _TriviaUser;

  factory TriviaUser.fromJson(Map<String, dynamic> json) =>
      _$TriviaUserFromJson(json);
}
