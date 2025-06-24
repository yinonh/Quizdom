import 'dart:io';
import 'dart:typed_data';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/global_providers/auth_providers.dart';
import 'package:trivia/core/utils/fluttermoji/fluttermoji_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/data/data_source/user_data_source.dart'; // Added import

part 'avatar_screen_manager.freezed.dart';
part 'avatar_screen_manager.g.dart';

@freezed
class AvatarState with _$AvatarState {
  const factory AvatarState({
    required String userName,
    required String? currentUserUid,
    required bool showImage,
    String? currentImage,
    File? selectedImage,
    File? originalImage,
    required CustomImageCropController cropController,
    @Default(false) bool showTrashIcon,
    @Default(false) bool navigate,
    @Default(false) bool isAnonymousUser,
  }) = _AvatarState;
}

@riverpod
class AvatarScreenManager extends _$AvatarScreenManager {
  @override
  Future<AvatarState> build() async {
    final currentUser = ref.read(authProvider).currentUser;
    String? userImage = currentUser.imageUrl;
    final prefs = await SharedPreferences.getInstance();
    final originalImagePath = prefs
        .getString("${Strings.originalUserImagePathKey} - ${currentUser.uid}");
    final originalImage =
        originalImagePath != null ? File(originalImagePath) : null;

    final bool isAnonymous = currentUser.isAnonymous;

    return AvatarState(
      userName: currentUser.name ?? "",
      currentUserUid: currentUser.uid,
      showImage: userImage != null && !isAnonymous, // Don't show image for anonymous users initially
      currentImage: userImage,
      selectedImage: null,
      originalImage: originalImage,
      cropController: CustomImageCropController(),
      isAnonymousUser: isAnonymous,
    );
  }

  void switchImage(XFile? image) {
    state.whenData(
      (data) {
        if (data.isAnonymousUser) {
          // Prevent anonymous users from selecting an image
          // Optionally, show a message or simply do nothing
          print("Anonymous users cannot select profile images."); // TODO: Show user message
          state = AsyncValue.data(
            data.copyWith(
              originalImage: null,
              selectedImage: null,
              showImage: false, // Ensure we switch to avatar mode
            )
          );
          return;
        }
        state = AsyncValue.data(
          data.copyWith(
            originalImage: image != null ? File(image.path) : null,
            selectedImage: image != null ? File(image.path) : null,
            showImage: image != null,
          ),
        );
      },
    );
  }

  Future<File> convertMemoryImageToFile(
    state.whenData(
      (data) {
        state = AsyncValue.data(
          data.copyWith(
            originalImage: image != null ? File(image.path) : null,
            selectedImage: image != null ? File(image.path) : null,
            showImage: image != null,
          ),
        );
      },
    );
  }

  Future<File> convertMemoryImageToFile(
      MemoryImage memoryImage, String fileName) async {
    final Uint8List byteData = memoryImage.bytes;

    final Directory tempDir = await getApplicationDocumentsDirectory();
    final String tempPath = tempDir.path;

    final File file = File('$tempPath/$fileName');

    await file.writeAsBytes(byteData);

    return file;
  }

  Future<void> saveImage() async {
    state.whenData((data) async {
      if (data.isAnonymousUser) {
        // If user is anonymous, force save as avatar and clear any image stuff.
        print("Anonymous users cannot save profile images. Defaulting to avatar."); // TODO: User message/logic
        if (data.currentUserUid != null && data.currentUserUid!.isNotEmpty) {
          await UserDataSource.deleteUserImageIfExists(data.currentUserUid!);
          // Also ensure avatar is set if we are clearing an image
          // This might involve ensuring fluttermoji options are saved if they changed
        }
        await saveAvatar(); // This saves the current fluttermoji
        // Ensure state reflects that we are in avatar mode.
        state = AsyncValue.data(data.copyWith(
            showImage: false,
            selectedImage: null,
            originalImage: null,
            currentImage: null,
            navigate: true // Assuming saveAvatar sets navigation or we do it here
        ));
        return;
      }

      if (data.currentUserUid == null || data.currentUserUid!.isEmpty) return; // Added empty check
      ref.read(loadingProvider.notifier).state = true;
      final MemoryImage? croppedImage = await data.cropController.onCropImage();

      if (croppedImage != null) {
        String currentTime = DateTime.now().toString();
        final byteData = croppedImage.bytes;
        final buffer = byteData.buffer;

        final appDir = await getApplicationDocumentsDirectory();
        final imagePath = Strings.getCroppedImagePath(appDir.path, currentTime);
        final file = File(imagePath);
        await file.writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

        if (data.originalImage != null) {
          // Now copy the file to the Application Documents Directory
          final originalImagePath =
              Strings.getOriginalImagePath(appDir.path, currentTime);
          await data.originalImage!.copy(originalImagePath);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              "${Strings.originalUserImagePathKey} - ${data.currentUserUid}",
              originalImagePath);
        }

        await ref.read(authProvider.notifier).setImage(file);
      }
      ref.read(newUserRegistrationProvider.notifier).clearNewUser();
      state = AsyncValue.data(data.copyWith(navigate: true));
      ref.read(loadingProvider.notifier).state = false;
    });
  }

  void toggleShowTrashIcon([bool? value]) {
    state.whenData((data) {
      state = AsyncValue.data(data.copyWith(
        showTrashIcon: value ?? !data.showTrashIcon,
      ));
    });
  }

  Future<void> saveAvatar() async {
    ref.read(loadingProvider.notifier).state = true;
    await ref.read(fluttermojiNotifierProvider.notifier).setFluttermoji();
    await ref.read(authProvider.notifier).setAvatar();
    state.whenData(
      (data) {
        ref.read(newUserRegistrationProvider.notifier).clearNewUser();
        state = AsyncValue.data(data.copyWith(navigate: true));
      },
    );
    ref.read(loadingProvider.notifier).state = false;
  }

  Future<void> revertChanges() async {
    await ref.read(fluttermojiNotifierProvider.notifier).restoreState();
  }
}
