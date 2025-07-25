import 'dart:io';

import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:Quizdom/core/utils/fluttermoji/fluttermoji_assets/fluttermojimodel.dart';
import 'package:Quizdom/core/utils/timestamp_converter.dart';

part 'trivia_user.freezed.dart';
part 'trivia_user.g.dart';

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
    required String uid,
    String? name,
    String? email,
    @JsonKey(name: "userImage") String? imageUrl,
    @JsonKey(name: "userAvatar") String? avatarUrl,
    @TimestampConverter() DateTime? lastLogin,
    @Default([]) List<int> recentTriviaCategories,
    Map<String, dynamic>? fluttermojiOptions,
    @Default([]) List<dynamic> trophies,
    @Default(100) int coins,
    @Default(false) bool isAnonymous,
  }) = _TriviaUser;

  const TriviaUser._();

  factory TriviaUser.fromJson(Map<String, dynamic> json) =>
      _$TriviaUserFromJson(json);

  // Factory constructor for creating default user
  factory TriviaUser.createDefault({
    required String uid,
    String? name,
    String? email,
    String? imageUrl,
    bool isAnonymous = false, // Add isAnonymous parameter
  }) {
    return TriviaUser(
      uid: uid,
      name: name ?? (isAnonymous ? 'Guest' : null), // Default name for guests
      email: email,
      imageUrl: imageUrl,
      lastLogin: DateTime.now(),
      recentTriviaCategories: [],
      fluttermojiOptions: defaultFluttermojiOptions,
      trophies: [],
      coins: 100,
      isAnonymous: isAnonymous,
    );
  }

  // Factory constructor from Firebase User
  factory TriviaUser.fromFirebaseUser(User firebaseUser) {
    final defaultName = firebaseUser.isAnonymous
        ? 'Guest'
        : firebaseUser.displayName ??
            firebaseUser.email?.split('@')[0] ??
            'User${firebaseUser.uid.substring(0, 4)}';

    return TriviaUser.createDefault(
      uid: firebaseUser.uid,
      name: defaultName,
      email: firebaseUser.email,
      imageUrl: AppConstant.imagesAllowed ? firebaseUser.photoURL : null,
      isAnonymous: firebaseUser.isAnonymous,
    );
  }

  // Convert to map for Firestore (excluding uid as it's the document ID)
  Map<String, dynamic> toFirestoreMap() {
    final json = toJson();
    json.remove('uid'); // Remove uid as it's the document ID
    return json;
  }

  // Method to create updated copy with new coin amount
  TriviaUser withUpdatedCoins(int newCoins) {
    return copyWith(coins: newCoins);
  }

  // Method to update recent categories
  TriviaUser withUpdatedCategories(int categoryId) {
    final List<int> updatedCategories = List.from(recentTriviaCategories);
    updatedCategories.remove(categoryId);
    updatedCategories.insert(0, categoryId);

    if (updatedCategories.length > 4) {
      updatedCategories.removeLast();
    }

    return copyWith(recentTriviaCategories: updatedCategories);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TriviaUser && uid.isNotEmpty && other.uid == uid);
  }

  @override
  int get hashCode => uid.hashCode;
}
