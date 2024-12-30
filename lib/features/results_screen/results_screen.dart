import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podium/flutter_podium.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/common_widgets/custom_progress_indicator.dart';
import 'package:trivia/core/common_widgets/user_app_bar.dart';
import 'package:trivia/features/results_screen/view_model/result_screen_manager.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/features/results_screen/widgets/top_user_podium.dart';

class ResultsScreen extends ConsumerWidget {
  static const routeName = Strings.resultsRouteName;

  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultState = ref.watch(resultScreenManagerProvider);

    return BaseScreen(
      child: Scaffold(
        appBar: UserAppBar(
          prefix: IconButton(
            icon: const Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: resultState.when(
          data: (data) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Carousel for Achievements
                CarouselSlider(
                  items: [
                    if (data.userAchievements.correctAnswers > 0)
                      _buildAchievementCard(
                        title: Strings.correctAnswers,
                        value: data.userAchievements.correctAnswers.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    if (data.userAchievements.wrongAnswers > 0)
                      _buildAchievementCard(
                        title: Strings.wrongAnswers,
                        value: data.userAchievements.wrongAnswers.toString(),
                        icon: Icons.cancel,
                        color: Colors.red,
                      ),
                    if (data.userAchievements.unanswered > 0)
                      _buildAchievementCard(
                        title: Strings.didntAnswer,
                        value: data.userAchievements.unanswered.toString(),
                        icon: Icons.help_outline,
                        color: Colors.grey,
                      ),
                    _buildAchievementCard(
                      title: Strings.averageTime,
                      value: data.avgTime.toStringAsFixed(2),
                      icon: Icons.timer,
                      color: Colors.blue,
                    ),
                  ],
                  options: CarouselOptions(
                    height: 200,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    viewportFraction: 0.5,
                    initialPage: 0,
                  ),
                ),
                const SizedBox(height: 20),

                // Podium for Top 3 Users
                const Text("Top 3 Players",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                (data.topUsers.length) >= 3
                    ? TopUsersPodium(
                        topUsersScores: data.topUsers,
                      )
                    : const Podium(
                        firstPosition: Text("first"),
                        secondPosition: Text("second"),
                        thirdPosition: Text("third"),
                      ),
                const SizedBox(height: 20),

                // List for Top 5 Users
                const Text("Top 5 Players", style: TextStyle(fontSize: 18)),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return const ListTile(
                        leading: Text("#name"),
                        title: Text("name 2"),
                        trailing: Text("name 3"),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          error: (_, __) => const SizedBox(),
          loading: () => const Center(child: CustomProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 50),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
