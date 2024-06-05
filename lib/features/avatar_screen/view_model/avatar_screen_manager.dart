import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivia/fluttermoji/fluttermojiFunctions.dart';

part 'avatar_screen_manager.freezed.dart';
part 'avatar_screen_manager.g.dart';

@freezed
class AvatarState with _$AvatarState {
  const factory AvatarState({
    required String userName,
  }) = _AvatarState;
}

@riverpod
class AvatarScreenManager extends _$AvatarScreenManager {
  @override
  Future<AvatarState> build() async {
    return AvatarState(userName: "Yinon");
  }

  Future<void> saveAvatar() async {
    final avatarSvg = await FluttermojiFunctions().encodeMySVGtoString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarSvg', avatarSvg);
  }
}
