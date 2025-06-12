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
  void Function()? _onAdDismissedCallback;
  void Function(AdError)? _onAdFailedToShowCallback;

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
              print('Ad Dismissed: $ad');
              ad.dispose();
              state = state.copyWith(isLoaded: false, adDisposed: true);
              _onAdDismissedCallback?.call();
              _clearCallbacks();
              loadAd(); // Reload a new ad
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              _logger.e('$ad onAdFailedToShowFullScreenContent: $error');
              print('Ad Failed to Show: $error');
              ad.dispose();
              state = state.copyWith(
                isLoaded: false,
                error: 'Failed to show ad: ${error.message}',
                adDisposed: true,
              );
              _onAdFailedToShowCallback?.call(error);
              _clearCallbacks();
              loadAd(); // Reload a new ad
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

  Future<void> showAd({
    void Function()? onDismiss,
    void Function(AdError)? onFail,
  }) async {
    _onAdDismissedCallback = onDismiss;
    _onAdFailedToShowCallback = onFail;

    if (state.isLoaded && state.interstitialAd != null) {
      _logger.i('Attempting to show Interstitial Ad...');
      print('Attempting to show Interstitial Ad...');
      await state.interstitialAd!.show();
      // Callbacks are handled by FullScreenContentCallback
    } else {
      _logger.w('Show ad request ignored, ad not loaded or null.');
      print('Show ad request ignored, ad not loaded or null.');
      // If ad is not loaded, immediately call the onFail callback as the show operation can't proceed.
      // Create a generic AdError if one isn't available.
      _onAdFailedToShowCallback?.call(AdError(0, 'AdNotLoaded', 'Ad is not loaded or null.'));
      _clearCallbacks();
      if (!state.isLoading) {
        loadAd();
      }
    }
  }

  void _clearCallbacks() {
    _onAdDismissedCallback = null;
    _onAdFailedToShowCallback = null;
  }

  @override
  void dispose() {
    _logger.i('Disposing AdNotifier, cleaning up ad resources.');
    state.interstitialAd?.dispose();
    _clearCallbacks();
    super.dispose();
  }
}

final interstitialAdProvider = StateNotifierProvider<AdNotifier, AdState>((ref) {
  return AdNotifier();
});
