import 'dart:io';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
    required CustomImageCropController cropController,
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
      cropController: CustomImageCropController(),
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
    // TODO: add original image so the user could crop difrently the image but use the cropped image
    final MemoryImage? croppedImage = await state.cropController.onCropImage();

    if (croppedImage != null) {
      // Convert MemoryImage to File and save it
      final byteData = await croppedImage.bytes;
      final buffer = byteData.buffer;

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/cropped_image.png';
      final file = File(imagePath);
      await file.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      await ref.read(userProvider.notifier).setImage(file.path);
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
