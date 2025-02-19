import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trivia/core/utils/timestamp_converter.dart';

part 'user_preference.freezed.dart';
part 'user_preference.g.dart';

@freezed
class UserPreference with _$UserPreference {
  const factory UserPreference({
    required int? questionCount,
    required int? categoryId,
    required String? difficulty,
    String? matchedUserId,
    String? triviaRoomId,
    @TimestampConverter() required DateTime? createdAt,
    bool? ready,
  }) = _UserPreference;

  factory UserPreference.empty() => const UserPreference(
        questionCount: null,
        categoryId: null,
        difficulty: null,
        matchedUserId: null,
        triviaRoomId: null,
        createdAt: null,
        ready: null,
      );

  factory UserPreference.fromJson(Map<String, dynamic> json) =>
      _$UserPreferenceFromJson(json);
}
