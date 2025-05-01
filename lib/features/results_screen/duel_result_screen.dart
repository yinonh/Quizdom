import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_when.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/results_screen/view_model/duel_screen_manager/duel_result_screen_manager.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/duel_results_header.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/player_stats_comparison.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/results_action_buttons.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/winner_announcement.dart';

class DuelResultsScreen extends ConsumerWidget {
  static const String routeName = Strings.duelResultsRouteName;
  final String roomId;

  const DuelResultsScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(duelResultScreenManagerProvider(roomId));

    return Scaffold(
      body: resultsAsync.customWhen(
        data: (resultsState) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DuelResultsHeader(resultsState: resultsState),
                      SizedBox(height: calcHeight(24)),
                      WinnerAnnouncement(resultsState: resultsState),
                      SizedBox(height: calcHeight(32)),
                      PlayerStatsComparison(resultsState: resultsState),
                      SizedBox(height: calcHeight(32)),
                      ResultsActionButtons(resultsState: resultsState),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
