import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/global_providers/ad_provider.dart';

class InterstitialAdWidget extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  final String? loadingText;
  final bool showSkipButton;
  final int skipDelaySeconds;

  const InterstitialAdWidget({
    super.key,
    required this.onComplete,
    this.onSkip,
    this.loadingText,
    this.showSkipButton = true,
    this.skipDelaySeconds = 5,
  });

  @override
  ConsumerState<InterstitialAdWidget> createState() =>
      _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends ConsumerState<InterstitialAdWidget> {
  bool _canSkip = false;
  bool _adRequested = false;
  int _remainingSeconds = 0;
  Timer? _skipTimer;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.skipDelaySeconds;

    // Start skip timer immediately if skip button is enabled
    if (widget.showSkipButton) {
      _startSkipTimer();
    }

    // Start fallback timer to auto-complete after delay
    _startFallbackTimer();

    // Request the ad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInterstitialAd();
    });
  }

  @override
  void dispose() {
    _skipTimer?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _startSkipTimer() {
    _skipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        setState(() {
          _canSkip = true;
        });
        timer.cancel();
      }
    });
  }

  void _startFallbackTimer() {
    // Auto-complete after maximum wait time (skip delay + 10 seconds buffer)
    _fallbackTimer = Timer(Duration(seconds: widget.skipDelaySeconds + 10), () {
      if (mounted && !_adRequested) {
        widget.onComplete();
      }
    });
  }

  void _showInterstitialAd() {
    if (_adRequested) return;
    _adRequested = true;

    final adNotifier = ref.read(adStateProvider.notifier);

    adNotifier.showInterstitialAd(
      onAdClosed: () {
        if (mounted) {
          _fallbackTimer?.cancel();
          widget.onComplete();
        }
      },
      onAdFailedToShow: () {
        if (mounted) {
          // If ad fails to show, wait for skip delay then proceed
          Future.delayed(Duration(seconds: widget.skipDelaySeconds), () {
            if (mounted) {
              widget.onComplete();
            }
          });
        }
      },
    );
  }

  void _handleSkip() {
    _skipTimer?.cancel();
    _fallbackTimer?.cancel();

    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final adState = ref.watch(adStateProvider);

    return Scaffold(
      backgroundColor: AppConstant.primaryColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstant.primaryColor,
              AppConstant.primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show loading only when ad is loading, not when showing
              if (adState.isLoading && !adState.isAdShowing)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),

              if (adState.isLoading && !adState.isAdShowing)
                const SizedBox(height: 24),

              // Loading text - only show when loading
              if (adState.isLoading && !adState.isAdShowing)
                Text(
                  widget.loadingText ?? 'Loading advertisement...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

              // Error message
              if (adState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Unable to load ad. Proceeding shortly...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Ad is showing message
              if (adState.isAdShowing) ...[
                const Icon(
                  Icons.ads_click,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Advertisement is displaying...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 40),

              // Skip button
              if (widget.showSkipButton)
                AnimatedOpacity(
                  opacity: _canSkip ? 1.0 : 0.6,
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: _canSkip ? _handleSkip : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppConstant.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _canSkip ? 'Skip Ad' : 'Skip in ${_remainingSeconds}s',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RewardedAdWidget extends ConsumerStatefulWidget {
  final Function(RewardItem reward) onRewardEarned;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  final String? title;
  final String? description;
  final String? rewardDescription;

  const RewardedAdWidget({
    super.key,
    required this.onRewardEarned,
    required this.onComplete,
    this.onSkip,
    this.title,
    this.description,
    this.rewardDescription,
  });

  @override
  ConsumerState<RewardedAdWidget> createState() => _RewardedAdWidgetState();
}

class _RewardedAdWidgetState extends ConsumerState<RewardedAdWidget> {
  bool _rewardEarned = false;
  bool _adRequested = false;

  void _showRewardedAd() {
    if (_adRequested) return;

    setState(() {
      _adRequested = true;
    });

    final adNotifier = ref.read(adStateProvider.notifier);

    adNotifier.showRewardedAd(
      onUserEarnedReward: (reward) {
        if (mounted) {
          setState(() {
            _rewardEarned = true;
          });
          widget.onRewardEarned(reward);
        }
      },
      onAdClosed: () {
        if (mounted) {
          widget.onComplete();
        }
      },
      onAdFailedToShow: () {
        if (mounted) {
          // Reset the request flag so user can try again
          setState(() {
            _adRequested = false;
          });
          // Optionally auto-complete after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              widget.onComplete();
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adState = ref.watch(adStateProvider);

    return Scaffold(
      backgroundColor: AppConstant.primaryColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstant.primaryColor,
              AppConstant.primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reward icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _rewardEarned ? Icons.check_circle : Icons.card_giftcard,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                _rewardEarned
                    ? 'Reward Earned!'
                    : (widget.title ?? 'Earn Reward'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                _rewardEarned
                    ? 'Congratulations! Your reward has been added.'
                    : (widget.description ??
                        'Watch a short advertisement to earn your reward'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              if (!_rewardEarned && widget.rewardDescription != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.rewardDescription!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 40),

              // Different states
              if (_rewardEarned) ...[
                // Reward earned - show completion button
                ElevatedButton(
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else if (adState.isLoading) ...[
                // Loading state
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading advertisement...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
              ] else if (adState.isAdShowing) ...[
                // Ad is showing
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Advertisement is playing...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
              ] else ...[
                // Ready to show ad
                ElevatedButton(
                  onPressed: _adRequested ? null : _showRewardedAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppConstant.primaryColor,
                    disabledBackgroundColor:
                        Colors.white.withValues(alpha: 0.5),
                    disabledForegroundColor:
                        AppConstant.primaryColor.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _adRequested ? 'Loading...' : 'Watch Ad',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Skip button
                if (widget.onSkip != null)
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],

              // Error message
              if (adState.error != null && !_rewardEarned) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Unable to load advertisement',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Reset error state and try again
                              setState(() {
                                _adRequested = false;
                              });
                            },
                            child: const Text(
                              'Try Again',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: widget.onComplete,
                            child: const Text(
                              'Continue',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
