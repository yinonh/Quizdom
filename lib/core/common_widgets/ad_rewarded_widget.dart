import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:trivia/core/constants/app_routes.dart';
import 'package:trivia/core/global_providers/ad_provider.dart';

import 'custom_progress_indicator.dart';

class RewardedAdWidget extends ConsumerStatefulWidget {
  static const String routeName = AppRoutes.rewardedAdRouteName;
  final Function(RewardItem reward) onRewardEarned;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const RewardedAdWidget({
    super.key,
    required this.onRewardEarned,
    required this.onComplete,
    this.onSkip,
  });

  @override
  ConsumerState<RewardedAdWidget> createState() => _RewardedAdWidgetState();
}

class _RewardedAdWidgetState extends ConsumerState<RewardedAdWidget> {
  bool _adRequested = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    // Start fallback timer to auto-complete after 10 seconds if ad doesn't load
    _startFallbackTimer();

    // Request the ad immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRewardedAd();
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _startFallbackTimer() {
    _fallbackTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_adRequested) {
        widget.onComplete();
      }
    });
  }

  void _showRewardedAd() {
    if (_adRequested) return;
    _adRequested = true;

    final adNotifier = ref.read(adProvider.notifier);

    adNotifier.showRewardedAd(
      onUserEarnedReward: (reward) {
        if (mounted) {
          _fallbackTimer?.cancel();
          widget.onRewardEarned(reward);
        }
      },
      onAdClosed: () {
        if (mounted) {
          _fallbackTimer?.cancel();
          widget.onComplete();
        }
      },
      onAdFailedToShow: () {
        if (mounted) {
          _fallbackTimer?.cancel();
          widget.onComplete();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          CustomProgressIndicator(),
        ],
      ),
    );
  }
}
