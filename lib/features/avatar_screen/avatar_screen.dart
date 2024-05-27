import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:fluttermoji/fluttermojiCustomizer.dart';
import 'package:fluttermoji/fluttermojiFunctions.dart';
import 'package:fluttermoji/fluttermojiThemeData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivia/features/avatar_screen/view_model/avatar_screen_manager.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';

class AvatarScreen extends ConsumerWidget {
  static const routeName = "/avatar";

  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarNotifier = ref.read(avatarScreenManagerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign in screen"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: FluttermojiCircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 70,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: FluttermojiCustomizer(
              autosave: true,
              theme: FluttermojiThemeData(
                  boxDecoration: BoxDecoration(boxShadow: [BoxShadow()])),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await avatarNotifier.saveAvatar();
              Navigator.pushReplacementNamed(
                  context, CategoriesScreen.routeName);
            },
            child: Text('Save Avatar'),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
