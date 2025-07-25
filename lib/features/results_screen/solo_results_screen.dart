import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/common_widgets/background.dart';
import 'package:Quizdom/core/common_widgets/base_screen.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/common_widgets/user_app_bar.dart';
import 'package:Quizdom/core/common_widgets/user_avatar.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/general_functions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/results_screen/view_model/solo_result_manager/solo_result_screen_manager.dart';
import 'package:Quizdom/features/results_screen/widgets/solo_widets/achievement_card.dart';
import 'package:Quizdom/features/results_screen/widgets/solo_widets/top_user_podium.dart';
import 'package:Quizdom/features/results_screen/widgets/total_score.dart';

class SoloResultsScreen extends ConsumerWidget {
  static const routeName = AppRoutes.soloResultsRouteName;

  const SoloResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultState = ref.watch(soloResultScreenManagerProvider);

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
              pop();
            },
          ),
        ),
        body: CustomBackground(
          child: resultState.customWhen(
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
                          iconColor: AppConstant.green,
                        ),
                      if (data.userAchievements.wrongAnswers > 0)
                        AchievementCard(
                          title: Strings.wrongAnswers,
                          value: data.userAchievements.wrongAnswers.toString(),
                          icon: Icons.cancel,
                          iconColor: AppConstant.red,
                        ),
                      if (data.userAchievements.unanswered > 0)
                        AchievementCard(
                          title: Strings.didntAnswer,
                          value: data.userAchievements.unanswered.toString(),
                          icon: Icons.help_outline,
                          iconColor: AppConstant.gray,
                        ),
                      AchievementCard(
                        title: Strings.averageTime,
                        value: data.avgTime.toStringAsFixed(2),
                        icon: Icons.timer,
                        iconColor: AppConstant.primaryColor,
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: calcHeight(15)),
                    child: TotalScore(score: data.totalScore),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: calcWidth(10)),
                    child: const Text(Strings.topPlayers,
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
                              margin: EdgeInsets.symmetric(
                                  vertical: calcHeight(5),
                                  horizontal: calcWidth(10)),
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
                                  "${score.toString()} ${Strings.pts}",
                                  style:
                                      const TextStyle(color: AppConstant.gray),
                                ),
                              ),
                            );
                          },
                        ),
                  SizedBox(height: calcHeight(20)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: restOfUsers.length,
                    itemBuilder: (context, index) {
                      final user = restOfUsers[index].key;
                      final score = restOfUsers[index].value;

                      return Card(
                        margin: EdgeInsets.symmetric(
                            vertical: calcWidth(5), horizontal: calcHeight(10)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: UserAvatar(
                            user: user,
                            radius: 15,
                          ),
                          onTap: () => showProfileOverview(context, user),
                          title: Text(
                            user.name ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            "${score.toString()} ${Strings.pts}",
                            style: const TextStyle(color: AppConstant.gray),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
