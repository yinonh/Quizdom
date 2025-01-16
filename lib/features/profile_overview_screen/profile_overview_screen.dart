import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/user.dart';
import 'package:trivia/features/profile_overview_screen/view_model/profile_overview_screen_manager.dart';

class ProfileOverview extends ConsumerWidget {
  final TriviaUser user;
  final VoidCallback? onClose;

  const ProfileOverview({
    required this.user,
    this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatsAsync = ref.watch(userStatisticsProvider(user.uid));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
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
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: calcWidth(120),
                    height: calcWidth(120),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppConstant.highlightColor.withValues(alpha: 0.3),
                    ),
                  ),
                  IgnorePointer(
                    child: UserAvatar(
                      user: user,
                      radius: 50,
                      showProgress: true,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user.name ?? Strings.mysteryPlayer,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${user.userXp.toStringAsFixed(1)} ${Strings.xp}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppConstant.goldColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              userStatsAsync.when(
                data: (stats) {
                  if (stats == null) return const SizedBox.shrink();
                  return Column(
                    spacing: calcHeight(12),
                    children: [
                      _buildStatSection(
                        title: Strings.gameStats,
                        icon: Icons.sports_esports,
                        color: AppConstant.onPrimaryColor,
                        stats: [
                          _buildStatRow(
                            icon: Icons.emoji_events,
                            label: Strings.victories,
                            value:
                                '${stats.gamesWon}/${stats.totalGamesPlayed}',
                          ),
                          _buildStatRow(
                            icon: Icons.local_fire_department,
                            label: Strings.winRate,
                            value:
                                '${((stats.gamesWon / stats.totalGamesPlayed) * 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                      _buildStatSection(
                        title: Strings.performance,
                        icon: Icons.insights,
                        color: AppConstant.secondaryColor,
                        stats: [
                          _buildStatRow(
                            icon: Icons.lightbulb,
                            label: Strings.accuracy,
                            value:
                                '${((stats.totalCorrectAnswers / (stats.totalCorrectAnswers + stats.totalWrongAnswers)) * 100).toStringAsFixed(0)}%',
                          ),
                          _buildStatRow(
                            icon: Icons.speed,
                            label: Strings.avgTime,
                            value: '${stats.avgAnswerTime.toStringAsFixed(1)}s',
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => _buildSkeletonLoader(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onClose?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstant.onPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text(Strings.close),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
