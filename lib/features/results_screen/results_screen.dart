import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_podium/flutter_podium.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/common_widgets/custom_progress_indicator.dart';
import 'package:trivia/core/common_widgets/user_app_bar.dart';
import 'package:trivia/data/service/general_trivia_room_provider.dart';
import 'package:trivia/features/results_screen/view_model/result_screen_manager.dart';
import 'package:trivia/core/constants/constant_strings.dart';

class ResultsScreen extends ConsumerWidget {
  static const routeName = Strings.resultsRouteName;

  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultState = ref.watch(resultScreenManagerProvider);
    final resultNotifier = ref.read(resultScreenManagerProvider.notifier);

    // Listen to the ResultState and update user score once the state is loaded
    ref.listen<AsyncValue<ResultState>>(
      resultScreenManagerProvider,
      (previous, next) async {
        if (next is AsyncData) {
          await resultNotifier.updateUserScoreOnServer();
        }
      },
    );
    final topUsers = ref
            .watch(generalTriviaRoomsProvider)
            .selectedRoom
            ?.topUsers
            .values
            .toList() ??
        [];

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
                    _buildAchievementCard(
                      title: Strings.correctAnswers,
                      value: data.userAchievements.correctAnswers.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _buildAchievementCard(
                      title: Strings.wrongAnswers,
                      value: data.userAchievements.wrongAnswers.toString(),
                      icon: Icons.cancel,
                      color: Colors.red,
                    ),
                    _buildAchievementCard(
                      title: Strings.didntAnswer,
                      value: data.userAchievements.unanswered.toString(),
                      icon: Icons.help_outline,
                      color: Colors.grey,
                    ),
                    _buildAchievementCard(
                      title: Strings.averageTime,
                      value: resultNotifier.getTimeAvg().toStringAsFixed(2),
                      icon: Icons.timer,
                      color: Colors.blue,
                    ),
                  ],
                  options: CarouselOptions(
                    height: 200,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                  ),
                ),
                const SizedBox(height: 20),

                // Podium for Top 3 Users
                const Text("Top 3 Players", style: TextStyle(fontSize: 18)),
                topUsers.length >= 3
                    ? Podium(
                        firstPosition: Text(topUsers[0].toString()),
                        secondPosition: Text(topUsers[1].toString()),
                        thirdPosition: Text(topUsers[2].toString()),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 50),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
