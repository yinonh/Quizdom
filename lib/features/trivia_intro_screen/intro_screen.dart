import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/background.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/common_widgets/custom_progress_indicator.dart';
import 'package:trivia/core/utils/enums/game_mode.dart';
import 'package:trivia/features/trivia_intro_screen/view_model/intro_screen_manager.dart';
import 'package:trivia/features/trivia_intro_screen/widgets/duel_content.dart';
import 'package:trivia/features/trivia_intro_screen/widgets/group_content.dart';
import 'package:trivia/features/trivia_intro_screen/widgets/solo_content.dart';

class TriviaIntroScreen extends ConsumerWidget {
  static const routeName = '/trivia-intro';

  const TriviaIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introStateAsync = ref.watch(introScreenManagerProvider);

    return BaseScreen(
      child: Scaffold(
        body: introStateAsync.when(
          loading: () => const Stack(
            children: [
              // Background with gradient
              CustomBackground(
                child: CustomProgressIndicator(),
              ),
            ],
          ),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (introState) => _buildContent(introState.gameMode),
        ),
      ),
    );
  }

  Widget _buildContent(GameMode mode) {
    switch (mode) {
      case GameMode.solo:
        return const SoloIntroContent();
      case GameMode.duel:
        return const DuelIntroContent();
      case GameMode.group:
        return const GroupIntroContent();
    }
  }
}
