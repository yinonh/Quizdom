import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/app_bar.dart';
import 'package:trivia/features/avatar_screen/view_model/avatar_screen_manager.dart';
import 'package:trivia/features/avatar_screen/widgets/edit_avatar.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/utalities/fluttermoji/fluttermojiCustomizer.dart';
import 'package:trivia/utalities/fluttermoji/fluttermojiThemeData.dart';

class AvatarScreen extends ConsumerWidget {
  static const routeName = "/avatar";

  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarScreenManagerProvider);
    final avatarNotifier = ref.read(avatarScreenManagerProvider.notifier);
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Sing in",
      ),
      body: GestureDetector(
        onTap: () {
          if (avatarState.selectedImage != null) {
            avatarNotifier.toggleShowTrashIcon(false);
          }
        },
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25.0),
              child: EditAvatar(),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
              child: FluttermojiCustomizer(
                autosave: false,
                theme: FluttermojiThemeData(
                    boxDecoration: BoxDecoration(boxShadow: [BoxShadow()])),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () async {
                  await avatarNotifier.saveAvatar();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 700),
                        pageBuilder: (_, __, ___) => const CategoriesScreen(),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Text(
                    'Save Avatar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
