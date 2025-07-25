// import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Quizdom/core/common_widgets/app_bar.dart';
import 'package:Quizdom/core/common_widgets/base_screen.dart';
import 'package:Quizdom/core/common_widgets/custom_button.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/fluttermoji/fluttermoji.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/avatar_screen/view_model/avatar_screen_manager.dart';
import 'package:Quizdom/features/avatar_screen/widgets/edit_avatar.dart';
import 'package:Quizdom/features/categories_screen/categories_screen.dart';

class AvatarScreen extends ConsumerWidget {
  static const routeName = AppRoutes.avatarRouteName;

  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarScreenManagerProvider);
    final avatarNotifier = ref.read(avatarScreenManagerProvider.notifier);

    ref.listen<AsyncValue<AvatarState>>(avatarScreenManagerProvider,
        (previous, next) {
      next.whenData((data) {
        if (data.navigate) {
          if (GoRouter.of(context).canPop()) {
            pop();
          } else {
            if (context.mounted) {
              goRoute(CategoriesScreen.routeName);
            }
          }
        }
      });
    });

    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        appBar: CustomAppBar(
          title: Strings.setAvatar,
          onBack: avatarNotifier.revertChanges,
        ),
        body: avatarState.customWhen(
          data: (state) => Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (AppConstant.imagesAllowed) {
                    if (state.selectedImage != null) {
                      avatarNotifier.toggleShowTrashIcon(false);
                    }
                  }
                },
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: calcHeight(60)),
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
                        child: AppConstant.imagesAllowed && state.showImage
                            ? SizedBox(
                                width: calcWidth(500),
                                height: calcHeight(300),
                                child: CustomImageCrop(
                                  cropController: state.cropController,
                                  image: state.originalImage != null
                                      ? FileImage(state.originalImage!)
                                      : NetworkImage(state.currentImage!)
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
                                    selectedIconColor:
                                        AppConstant.onPrimaryColor,
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
                      if (AppConstant.imagesAllowed && state.showImage) {
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
        ),
      ),
    );
  }
}
