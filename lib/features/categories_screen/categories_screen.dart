import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/background.dart';

import 'package:trivia/common_widgets/user_app_bar.dart';
import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:trivia/features/categories_screen/widgets/expandable_horizontal_list.dart';
import 'package:trivia/features/categories_screen/widgets/info_container.dart';
import 'package:trivia/features/categories_screen/widgets/top_button.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/size_config.dart';

class CategoriesScreen extends ConsumerWidget {
  static const routeName = "/categories_screen";

  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesScreenManagerProvider);

    return Scaffold(
      appBar: UserAppBar(),
      extendBodyBehindAppBar: true,
      body: CustomBackground(
        child: categoriesState.when(
          data: (data) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: calcHeight(160),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TopButton(
                        icon: Icons.add_rounded,
                        label: "Create Quiz",
                        color: AppConstant.highlightColor.toColor(),
                        onTap: () {
                          // Handle create quiz tap
                        },
                      ),
                      TopButton(
                        icon: Icons.person_2,
                        label: "Solo Mode",
                        color: AppConstant.secondaryColor.toColor(),
                        onTap: () {
                          // Handle solo mode tap
                        },
                      ),
                      TopButton(
                        icon: Icons.groups_2,
                        label: "Multiplayer",
                        color: AppConstant.onPrimary.toColor(),
                        onTap: () {
                          // Handle multiplayer tap
                        },
                      ),
                    ],
                  ),
                ),
                ExpandableHorizontalList(
                  categories: data.categories.triviaCategories,
                  title: "Featured Categories",
                ),
                InfoContainer(text: "Recent Quiz Information"),
                InfoContainer(text: "Personal Rooms Information"),
                InfoContainer(text: "Personal Rooms Information"),
                InfoContainer(text: "Personal Rooms Information"),
              ],
            ),
          ),
          error: (error, _) => Center(child: Text(error.toString())),
          loading: () => Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final categoriesState = ref.watch(categoriesScreenManagerProvider);
//     final categoriesNotifier =
//         ref.read(categoriesScreenManagerProvider.notifier);
//     return Scaffold(
//       appBar: const UserAppBar(),
//       body: categoriesState.when(data: (data) {
//         return ListView.builder(
//             itemCount: data.categories.triviaCategories?.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(data.categories.triviaCategories![index].name!),
//                 trailing: const Icon(Icons.arrow_forward_ios_rounded),
//                 onTap: () {
//                   categoriesNotifier.setCategory(
//                       data.categories.triviaCategories![index].id!);
//                   categoriesNotifier.resetAchievements();
//                   Navigator.pushNamed(context, QuizScreen.routeName);
//                 },
//               );
//             });
//       }, error: (error, _) {
//         return Text(error.toString());
//       }, loading: () {
//         return const CircularProgressIndicator();
//       }),
//     );
//   }
// }
