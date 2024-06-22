import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/app_bar.dart';
import 'package:trivia/features/avatar_screen/view_model/avatar_screen_manager.dart';
import 'package:trivia/features/avatar_screen/widgets/edit_avatar.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/fluttermoji/fluttermojiCustomizer.dart';
import 'package:trivia/utility/fluttermoji/fluttermojiThemeData.dart';
import 'package:trivia/utility/size_config.dart';

class AvatarScreen extends ConsumerWidget {
  static const routeName = "/avatar";

  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarScreenManagerProvider);
    final avatarNotifier = ref.read(avatarScreenManagerProvider.notifier);
    return Scaffold(
      backgroundColor: AppConstant.primaryColor.toColor(),
      appBar: const CustomAppBar(
        title: "Sing in",
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (avatarState.selectedImage != null) {
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
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 30, top: 100),
                    child: FluttermojiCustomizer(
                      autosave: false,
                      theme: FluttermojiThemeData(
                          selectedIconColor: AppConstant.onPrimary.toColor(),
                          boxDecoration:
                              const BoxDecoration(boxShadow: [BoxShadow()])),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: GestureDetector(
                onTap: () async {
                  await avatarNotifier.saveAvatar();
                  await avatarNotifier.saveImage();
                  if (context.mounted && Navigator.canPop(context)) {
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
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: AppConstant.secondaryColor.toColor(),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstant.secondaryColor
                            .toColor()
                            .withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 5,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Save',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -10,
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
                  child: const EditAvatar()),
            ),
          ),
        ],
      ),
    );
  }
}
