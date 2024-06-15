import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:trivia/service/user_provider.dart';
import 'package:trivia/utility/fluttermoji/fluttermojiController.dart';

part 'avatar_screen_manager.freezed.dart';
part 'avatar_screen_manager.g.dart';

@freezed
class AvatarState with _$AvatarState {
  const factory AvatarState({
    required String userName,
    File? selectedImage,
    required bool showTrashIcon,
  }) = _AvatarState;
}

@riverpod
class AvatarScreenManager extends _$AvatarScreenManager {
  @override
  AvatarState build() {
    File? userImage = ref.read(userProvider).userImage;
    return AvatarState(
      userName: "Yinon",
      showTrashIcon: false,
      selectedImage: userImage,
    );
  }

  void switchImage(XFile? image) {
    if (image != null) {
      state = state.copyWith(selectedImage: File(image.path));
    } else {
      state = state.copyWith(selectedImage: null);
    }
  }

  Future<void> saveImage() async {
    final image = state.selectedImage;
    if (image != null) {
      await ref.read(userProvider.notifier).setImage(image);
    } else {
      await ref.read(userProvider.notifier).setImage(null);
      state = state.copyWith(showTrashIcon: false);
    }
  }

  void toggleShowTrashIcon([bool? value]) {
    state = state.copyWith(showTrashIcon: value ?? !state.showTrashIcon);
  }

  Future<void> saveAvatar() async {
    final fluttermojiController = Get.find<FluttermojiController>();
    await fluttermojiController.setFluttermoji();
    await ref.read(userProvider.notifier).setAvatar();
  }
}
