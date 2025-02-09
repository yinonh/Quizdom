// import 'dart:async';
//
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:trivia/data/data_source/user_preference_data_source.dart';
// import 'package:trivia/data/models/user_preference.dart';
//
// part 'user_preference_provider.freezed.dart';
// part 'user_preference_provider.g.dart';
//
// @freezed
// class AvailableUsersState with _$AvailableUsersState {
//   const factory AvailableUsersState({
//     required Map<String, UserPreference>? availableUsers,
//     String? error,
//   }) = _AvailableUsersState;
// }
//
// @riverpod
// class AvailableUsers extends _$AvailableUsers {
//   StreamSubscription<Map<String, UserPreference>>? _availableUsersSubscription;
//
//   @override
//   AvailableUsersState build() {
//     // Start watching immediately if needed
//     _startWatching();
//
//     // Clean up on dispose
//     ref.onDispose(() {
//       _availableUsersSubscription?.cancel();
//     });
//
//     return const AvailableUsersState(availableUsers: null);
//   }
//
//   void _startWatching() {
//     _availableUsersSubscription?.cancel();
//
//     _availableUsersSubscription = UserPreferenceDataSource.watchAvailableUsers()
//         .distinct() // Only emit when the data actually changes
//         .listen(
//       (rooms) {
//         if (rooms != state.availableUsers) {
//           // Only update if there's a change
//           state = state.copyWith(availableUsers: rooms);
//         }
//       },
//       onError: (error) {
//         state = state.copyWith(error: error.toString());
//       },
//     );
//   }
//
//   Future<void> createUserPreference({
//     required String userId,
//     int? questionCount,
//     int? categoryId,
//     String? difficulty,
//   }) async {
//     await UserPreferenceDataSource.createUserPreference(
//       userId: userId,
//       preference: UserPreference(
//         questionCount: questionCount,
//         categoryId: categoryId,
//         difficulty: difficulty,
//         createdAt: DateTime.now(),
//       ),
//     );
//   }
//
//   Future<void> deleteUserPreference(String userId) async {
//     await UserPreferenceDataSource.deleteUserPreference(userId);
//   }
//
//   Future<void> updateUserPreference({
//     required String userId,
//     int? questionCount,
//     int? categoryId,
//     String? difficulty,
//   }) async {
//     await UserPreferenceDataSource.updateUserPreference(
//       userId: userId,
//       updatedPreference: UserPreference(
//         questionCount: questionCount,
//         categoryId: categoryId,
//         difficulty: difficulty,
//         createdAt: DateTime.now(),
//       ),
//     );
//   }
// }
