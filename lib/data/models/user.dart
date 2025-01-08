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
  @Assert('uid != null', 'uid cannot be null when used as a map key')
  const factory TriviaUser({
    required String? uid,
    String? name,
    String? email,
    String? imageUrl,
    required UserAchievements achievements,
    required DateTime lastLogin,
    required List<int> recentTriviaCategories,
    required List<int> trophies,
    required double userXp,
    Map<String, dynamic>? fluttermojiOptions,
  }) = _TriviaUser;

  const TriviaUser._();

  factory TriviaUser.fromJson(Map<String, dynamic> json) =>
      _$TriviaUserFromJson(json);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TriviaUser && uid != null && other.uid == uid);
  }

  @override
  int get hashCode => uid.hashCode;
}
