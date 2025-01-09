import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/background.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/common_widgets/custom_progress_indicator.dart';
import 'package:trivia/core/common_widgets/user_app_bar.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/results_screen/view_model/result_screen_manager.dart';
import 'package:trivia/features/results_screen/widgets/achievement_card.dart';
import 'package:trivia/features/results_screen/widgets/top_user_podium.dart';

class ResultsScreen extends ConsumerWidget {
  static const routeName = Strings.resultsRouteName;

  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultState = ref.watch(resultScreenManagerProvider);

    return BaseScreen(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: UserAppBar(
          isEditable: false,
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
        body: CustomBackground(
          child: resultState.when(
            data: (data) {
              final sortedUsers = data.topUsers.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              // Separate the top 3 users for the podium and the rest
              final topThreeUsers = sortedUsers.take(3).toList();
              final restOfUsers = sortedUsers.skip(3).take(7).toList();
              return ListView(
                children: [
                  CarouselSlider(
                    items: [
                      if (data.userAchievements.correctAnswers > 0)
                        AchievementCard(
                          title: Strings.correctAnswers,
                          value:
                              data.userAchievements.correctAnswers.toString(),
                          icon: Icons.check_circle,
                          iconColor: Colors.green,
                        ),
                      if (data.userAchievements.wrongAnswers > 0)
                        AchievementCard(
                          title: Strings.wrongAnswers,
                          value: data.userAchievements.wrongAnswers.toString(),
                          icon: Icons.cancel,
                          iconColor: Colors.red,
                        ),
                      if (data.userAchievements.unanswered > 0)
                        AchievementCard(
                          title: Strings.didntAnswer,
                          value: data.userAchievements.unanswered.toString(),
                          icon: Icons.help_outline,
                          iconColor: Colors.grey,
                        ),
                      AchievementCard(
                        title: Strings.averageTime,
                        value: data.avgTime.toStringAsFixed(2),
                        icon: Icons.timer,
                        iconColor: Colors.blue,
                      ),
                    ],
                    options: CarouselOptions(
                      height: calcHeight(250),
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      viewportFraction: 0.5,
                      initialPage: 0,
                    ),
                  ),
                  // const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    width: double.infinity,
                    child: Card(
                      color: AppConstant.onPrimary,
                      child: Column(
                        children: [
                          const Text(
                            Strings.totalScore,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.totalScore.toString(),
                            style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(Strings.topPlayers,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  (data.topUsers.length) >= 3
                      ? TopUsersPodium(
                          topUsersScores: topThreeUsers,
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: topThreeUsers.length,
                          itemBuilder: (context, index) {
                            final user = topThreeUsers[index].key;
                            final score = topThreeUsers[index].value;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                              child: ListTile(
                                leading: UserAvatar(
                                  user: user,
                                  radius: 15,
                                ),
                                title: Text(
                                  user.name ?? "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Text(
                                  "${score.toString()} pts",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: restOfUsers.length,
                    itemBuilder: (context, index) {
                      final user = restOfUsers[index].key;
                      final score = restOfUsers[index].value;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: UserAvatar(
                            user: user,
                            radius: 15,
                          ),
                          title: Text(
                            user.name ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            "${score.toString()} pts",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
            error: (_, __) => const SizedBox(),
            loading: () => const Center(child: CustomProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
