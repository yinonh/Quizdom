import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/network/server.dart';

part 'ad_provider.g.dart';

class AdService {
  static AdService? _instance;

  static AdService get instance => _instance ??= AdService._();

  AdService._();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Test Ad Unit IDs
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Production Ad Unit IDs - Replace with your actual IDs
  static const String _prodInterstitialAdUnitIdAndroid =
      'ca-app-pub-YOUR_ID/YOUR_ANDROID_INTERSTITIAL_ID';
  static const String _prodRewardedAdUnitIdAndroid =
      'ca-app-pub-YOUR_ID/YOUR_ANDROID_REWARDED_ID';

  // Get the appropriate ad unit ID based on debug/release mode
  String get interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitialAdUnitId;
    }
    return _prodInterstitialAdUnitIdAndroid;
  }

  String get rewardedAdUnitId {
    if (kDebugMode) {
      return _testRewardedAdUnitId;
    }
    return _prodRewardedAdUnitIdAndroid;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();

      // Only add test device IDs in debug mode
      if (kDebugMode) {
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
              testDeviceIds: ['C98B7A1D528A9F7EEDA21E0489CBBB8C']),
        );
      }

      _isInitialized = true;
      if (kDebugMode) {
        logger.i('AdMob initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.e('Failed to initialize AdMob: $e');
      }
    }
  }

  Future<InterstitialAd?> loadInterstitialAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    final completer = Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            logger.i('Interstitial ad loaded successfully');
          }
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            logger.e('Failed to load interstitial ad: $error');
          }
          completer.complete(null);
        },
      ),
    );

    return completer.future;
  }

  Future<RewardedAd?> loadRewardedAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    final completer = Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            logger.i('Rewarded ad loaded successfully');
          }
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            logger.e('Failed to load rewarded ad: $error');
          }
          completer.complete(null);
        },
      ),
    );

    return completer.future;
  }
}

// State notifier for managing ad states
class AdState {
  final bool isLoading;
  final bool isAdShowing;
  final String? error;

  const AdState({
    this.isLoading = false,
    this.isAdShowing = false,
    this.error,
  });

  AdState copyWith({
    bool? isLoading,
    bool? isAdShowing,
    String? error,
  }) {
    return AdState(
      isLoading: isLoading ?? this.isLoading,
      isAdShowing: isAdShowing ?? this.isAdShowing,
      error: error ?? this.error,
    );
  }
}

@riverpod
class Ad extends _$Ad {
  late final AdService _adService;

  @override
  AdState build() {
    _adService = ref.watch(adServiceProvider);
    return const AdState();
  }

  Future<void> showInterstitialAd({
    required VoidCallback onAdClosed,
    VoidCallback? onAdFailedToShow,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final ad = await _adService.loadInterstitialAd();

      if (ad == null) {
        state = state.copyWith(isLoading: false, error: 'Failed to load ad');
        onAdFailedToShow?.call();
        return;
      }

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          if (kDebugMode) {
            logger.i('Interstitial ad showed full screen content');
          }
          state = state.copyWith(isLoading: false, isAdShowing: true);
        },
        onAdDismissedFullScreenContent: (ad) {
          if (kDebugMode) {
            logger.i('Interstitial ad dismissed');
          }
          state = state.copyWith(isAdShowing: false);
          ad.dispose();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) {
            logger.e('Failed to show interstitial ad: $error');
          }
          state = state.copyWith(isLoading: false, error: error.message);
          ad.dispose();
          onAdFailedToShow?.call();
        },
      );

      await ad.show();
    } catch (e) {
      if (kDebugMode) {
        logger.e('Error showing interstitial ad: $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      onAdFailedToShow?.call();
    }
  }

  Future<void> showRewardedAd({
    required void Function(RewardItem) onUserEarnedReward,
    required VoidCallback onAdClosed,
    VoidCallback? onAdFailedToShow,
  }) async {
    // Use Future.microtask to defer state changes
    Future.microtask(() {
      state = state.copyWith(isLoading: true, error: null);
    });

    try {
      final ad = await _adService.loadRewardedAd();

      if (ad == null) {
        Future.microtask(() {
          state = state.copyWith(
              isLoading: false, error: 'Failed to load rewarded ad');
        });
        onAdFailedToShow?.call();
        return;
      }

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          Future.microtask(() {
            state = state.copyWith(isLoading: false, isAdShowing: true);
          });
          if (kDebugMode) {
            logger.i('Rewarded ad showed full screen content');
          }
        },
        onAdDismissedFullScreenContent: (ad) {
          Future.microtask(() {
            state = state.copyWith(isAdShowing: false);
          });
          ad.dispose();
          onAdClosed();
          if (kDebugMode) {
            logger.i('Rewarded ad dismissed');
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          Future.microtask(() {
            state = state.copyWith(isLoading: false, error: error.message);
          });
          ad.dispose();
          onAdFailedToShow?.call();
          if (kDebugMode) {
            logger.e('Failed to show rewarded ad: $error');
          }
        },
      );

      await ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onUserEarnedReward(reward);
        },
      );
    } catch (e) {
      Future.microtask(() {
        state = state.copyWith(isLoading: false, error: e.toString());
      });
      onAdFailedToShow?.call();
      if (kDebugMode) {
        logger.e('Error showing rewarded ad: $e');
      }
    }
  }
}

// Provider for the ad service
@riverpod
AdService adService(Ref ref) {
  return AdService.instance;
}
