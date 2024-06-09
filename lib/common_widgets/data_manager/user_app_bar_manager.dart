// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:trivia/service/trivia_provider.dart';
//
// import 'package:trivia/models/trivia_categories.dart';
// import 'package:trivia/service/user_provider.dart';
//
// part 'user_app_bar_manager.freezed.dart';
// part 'user_app_bar_manager.g.dart';
//
// @freezed
// class UserAppBarState with _$UserAppBarState {
//   const factory UserAppBarState({
//     String? userAvatar,
//   }) = _UserAppBarState;
// }
//
// @riverpod
// class UserAppBarManager extends _$UserAppBarManager {
//   @override
//   Future<UserAppBarState> build() async {
//     return UserAppBarState(
//         userAvatar: await fetchAvatar());
//   }
//
//   Future<String?> fetchAvatar() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('fluttermoji');
//   }
// }
