import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/common_widgets/user_avatar.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/general_functions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/data/models/trivia_user.dart';
import 'package:Quizdom/features/profile_overview_screen/view_model/profile_overview_screen_manager.dart';

class ProfileBottomSheet extends ConsumerWidget {
  final TriviaUser user;

  const ProfileBottomSheet({
    required this.user,
    super.key,
  });

  // Method to show the bottom sheet
  static Future<void> show(BuildContext context, TriviaUser user) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProfileBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatsAsync = ref.watch(userStatisticsProvider(user.uid));

    // Calculate the avatar size and its position
    final avatarRadius = calcWidth(55);
    final avatarPosition = avatarRadius;

    return SafeArea(
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.only(top: avatarPosition),
            padding: EdgeInsets.only(
              top: avatarPosition + calcHeight(16),
              left: calcWidth(24),
              right: calcWidth(24),
              bottom: calcHeight(24),
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstant.primaryColor,
                  AppConstant.highlightColor,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                spacing: calcHeight(20),
                mainAxisSize: MainAxisSize.min,
                children: [
                  userStatsAsync.customWhen(
                    data: (stats) {
                      if (stats == null) return const SizedBox.shrink();
                      return Column(
                        spacing: calcHeight(12),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                user.name ?? Strings.mysteryPlayer,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${formatNumber(stats.totalScore)} ${Strings.xp}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppConstant.goldColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          _buildStatSection(
                            title: Strings.gameStats,
                            icon: Icons.sports_esports_rounded,
                            color: AppConstant.onPrimaryColor,
                            stats: [
                              _buildStatRow(
                                icon: Icons.emoji_events_rounded,
                                label: Strings.victories,
                                value:
                                    '${stats.gamesWon}/${stats.gamesPlayedAgainstPlayers}',
                              ),
                              _buildStatRow(
                                icon: Icons.local_fire_department_rounded,
                                label: Strings.winRate,
                                value:
                                    '${((stats.gamesWon / stats.gamesPlayedAgainstPlayers) * 100).toStringAsFixed(0)}%',
                              ),
                              _buildStatRow(
                                icon: Icons.games_rounded,
                                label: Strings.gamesPlayed,
                                value: '${stats.totalGamesPlayed}',
                              ),
                            ],
                          ),
                          _buildStatSection(
                            title: Strings.performance,
                            icon: Icons.insights_rounded,
                            color: AppConstant.secondaryColor,
                            stats: [
                              _buildStatRow(
                                icon: Icons.lightbulb,
                                label: Strings.accuracy,
                                value:
                                    '${((stats.totalCorrectAnswers / (stats.totalCorrectAnswers + stats.totalWrongAnswers)) * 100).toStringAsFixed(0)}%',
                              ),
                              _buildStatRow(
                                icon: Icons.speed_rounded,
                                label: Strings.avgTime,
                                value:
                                    '${stats.avgAnswerTime.toStringAsFixed(1)}s',
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => _buildSkeletonLoader(),
                  ),
                  SizedBox(height: calcHeight(16)),
                ],
              ),
            ),
          ),

          // User avatar positioned half above the sheet
          Positioned(
            top: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstant.highlightColor,
                  ),
                ),
                UserAvatar(
                  user: user,
                  radius: avatarRadius.toDouble(),
                  disabled: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!.withValues(alpha: 0.3),
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: calcHeight(100),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> stats,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstant.highlightColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: calcHeight(12),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: calcWidth(8),
            children: [
              Icon(icon, color: color, size: 18),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          ...stats,
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          SizedBox(width: calcWidth(8)),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
