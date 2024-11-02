import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/app_bar.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/common_widgets/custom_progress_indicator.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/fluttermoji/fluttermoji.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/avatar_screen/view_model/avatar_screen_manager.dart';
import 'package:trivia/features/avatar_screen/widgets/edit_avatar.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';

class AvatarScreen extends ConsumerWidget {
  static const routeName = Strings.avatarRouteName;

  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarScreenManagerProvider);
    final avatarNotifier = ref.read(avatarScreenManagerProvider.notifier);

    ref.listen<AsyncValue<AvatarState>>(avatarScreenManagerProvider,
        (previous, next) {
      next.whenData((data) {
        if (data.navigate) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 700),
                  pageBuilder: (_, __, ___) => const CategoriesScreen(),
                ),
              );
            }
          }
        }
      });
    });

    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        appBar: CustomAppBar(
          title: Strings.setImage,
          onBack: avatarNotifier.revertChanges,
        ),
        body: avatarState.when(
          data: (state) => Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (state.selectedImage != null) {
                    avatarNotifier.toggleShowTrashIcon(false);
                  }
                },
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 60),
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35.0),
                      topRight: Radius.circular(35.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: calcWidth(20),
                          right: calcWidth(20),
                          bottom: calcHeight(30),
                          top: calcHeight(100),
                        ),
                        child: state.showImage
                            ? SizedBox(
                                width: calcWidth(500),
                                height: calcHeight(300),
                                child: CustomImageCrop(
                                  cropController: state.cropController,
                                  image: FileImage(state.originalImage!)
                                      as ImageProvider<Object>,
                                  shape: CustomCropShape.Circle,
                                  canRotate: true,
                                  canMove: true,
                                  canScale: true,
                                  imageFit: CustomImageFit.fillCropSpace,
                                  pathPaint: Paint()
                                    ..strokeWidth = 2.0
                                    ..strokeJoin = StrokeJoin.round,
                                ),
                              )
                            : FluttermojiCustomizer(
                                autosave: false,
                                theme: FluttermojiThemeData(
                                    selectedIconColor: AppConstant.onPrimary,
                                    boxDecoration: const BoxDecoration(
                                        boxShadow: [BoxShadow()])),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: calcHeight(50),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: calcWidth(13)),
                  child: CustomButton(
                    text: Strings.save,
                    onTap: () async {
                      if (state.showImage) {
                        avatarNotifier.saveImage();
                      } else {
                        avatarNotifier.saveAvatar();
                      }
                    },
                    padding: EdgeInsets.symmetric(vertical: calcHeight(15)),
                    color: AppConstant.secondaryColor,
                  ),
                ),
              ),
              Positioned(
                top: calcHeight(-10),
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Container(
                    width: calcWidth(155),
                    height: calcWidth(155),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const EditAvatar(),
                  ),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CustomProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('${Strings.error} $error')),
        ),
      ),
    );
  }
}
