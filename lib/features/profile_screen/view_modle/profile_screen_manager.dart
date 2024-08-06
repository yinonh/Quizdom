import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/service/user_provider.dart';

part 'profile_screen_manager.freezed.dart';

part 'profile_screen_manager.g.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    String? userAvatar,
  }) = _ProfileState;
}

@riverpod
class ProfileScreenManager extends _$ProfileScreenManager {
  @override
  Future<ProfileState> build() async {
    final userState = ref.read(userProvider).currentUser;
    return ProfileState(
      userAvatar: userState.avatar,
    );
  }
}
