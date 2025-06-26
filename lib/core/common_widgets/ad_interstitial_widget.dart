import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/global_providers/ad_provider.dart';

import 'custom_progress_indicator.dart';

class InterstitialAdWidget extends ConsumerStatefulWidget {
  static const String routeName = AppRoutes.interstitialAdRouteName;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const InterstitialAdWidget({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  ConsumerState<InterstitialAdWidget> createState() =>
      _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends ConsumerState<InterstitialAdWidget> {
  bool _adRequested = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    // Start fallback timer to auto-complete after 10 seconds if ad doesn't load
    _startFallbackTimer();

    // Request the ad immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInterstitialAd();
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

  void _showInterstitialAd() {
    if (_adRequested) return;
    _adRequested = true;

    final adNotifier = ref.read(adProvider.notifier);

    adNotifier.showInterstitialAd(
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
    // Completely transparent widget - user only sees the actual ad
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const CustomProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
