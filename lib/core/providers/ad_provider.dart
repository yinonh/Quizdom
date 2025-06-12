import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

class AdState {
  final InterstitialAd? interstitialAd;
  final bool isLoading;
  final bool isLoaded;
  final String? error;

  AdState({
    this.interstitialAd,
    this.isLoading = false,
    this.isLoaded = false,
    this.error,
  });

  AdState copyWith({
    InterstitialAd? interstitialAd,
    bool? isLoading,
    bool? isLoaded,
    String? error,
    bool adDisposed = false, // Special flag to nullify ad
  }) {
    return AdState(
      interstitialAd: adDisposed ? null : interstitialAd ?? this.interstitialAd,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error ?? this.error,
    );
  }
}

class AdNotifier extends StateNotifier<AdState> {
  AdNotifier() : super(AdState()) {
    _initializeAds();
  }

  Future<void> _initializeAds() async {
    try {
      final initStatus = await MobileAds.instance.initialize();
      _logger.i('Mobile Ads SDK initialized: $initStatus');
      // After initialization, load the first ad
      loadAd();
    } catch (e) {
      _logger.e('Mobile Ads SDK initialization failed: $e');
      state = state.copyWith(error: 'SDK Initialization Failed: $e');
    }
  }

  Future<void> loadAd() async {
    if (state.isLoading || state.isLoaded) {
      _logger.i('Ad load request ignored, already loading or loaded.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    _logger.i('Loading Interstitial Ad...');

    await InterstitialAd.load(
      adUnitId: _testInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _logger.i('Interstitial Ad loaded.');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                _logger.i('$ad onAdShowedFullScreenContent.'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              _logger.i('$ad onAdDismissedFullScreenContent.');
              ad.dispose();
              state = state.copyWith(isLoaded: false, adDisposed: true);
              // Optionally, load a new ad
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              _logger.e('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              state = state.copyWith(
                isLoaded: false,
                error: 'Failed to show ad: ${error.message}',
                adDisposed: true,
              );
              // Optionally, load a new ad
              loadAd();
            },
          );
          state = state.copyWith(
              interstitialAd: ad, isLoading: false, isLoaded: true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _logger.e('Interstitial Ad failed to load: $error');
          state = state.copyWith(
            isLoading: false,
            isLoaded: false,
            error: error.message,
          );
        },
      ),
    );
  }

  Future<void> showAd() async {
    if (state.isLoaded && state.interstitialAd != null) {
      _logger.i('Showing Interstitial Ad...');
      await state.interstitialAd!.show();
      // The ad is disposed and state updated in onAdDismissedFullScreenContent
      // or onAdFailedToShowFullScreenContent
    } else {
      _logger.w('Show ad request ignored, ad not loaded or null.');
      if (!state.isLoading) {
        // If not already loading, try to load one
        loadAd();
      }
    }
  }

  @override
  void dispose() {
    _logger.i('Disposing AdNotifier, cleaning up ad resources.');
    state.interstitialAd?.dispose();
    super.dispose();
  }
}

final interstitialAdProvider = StateNotifierProvider<AdNotifier, AdState>((ref) {
  return AdNotifier();
});
