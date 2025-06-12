import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../providers/ad_provider.dart'; // Assuming ad_provider.dart is in lib/core/providers/

final Logger _logger = Logger();

class InterstitialAdManager extends ConsumerWidget {
  const InterstitialAdManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AdState>(interstitialAdProvider, (previous, next) {
      final bool wasLoaded = previous?.isLoaded ?? false;
      final bool isNowLoaded = next.isLoaded;
      final bool hasAdObject = next.interstitialAd != null;

      if (!wasLoaded && isNowLoaded && hasAdObject) {
        _logger.i('InterstitialAdManager: Ad transitioned to loaded state. Attempting to show.');
        // Important: Use a post-frame callback to ensure that showAd is not called
        // during a build cycle, which can happen with listeners.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Check again if the ad is still loaded and not null, in case state changed rapidly
          if (ref.read(interstitialAdProvider).isLoaded && ref.read(interstitialAdProvider).interstitialAd != null) {
             ref.read(interstitialAdProvider.notifier).showAd();
          } else {
            _logger.w('InterstitialAdManager: Ad was no longer loaded or null when showAd was about to be called.');
          }
        });
      } else if (isNowLoaded && hasAdObject && previous == null) {
        // This handles the case where the listener is attached and the ad is already loaded.
         _logger.i('InterstitialAdManager: Ad was already loaded when listener attached. Attempting to show.');
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (ref.read(interstitialAdProvider).isLoaded && ref.read(interstitialAdProvider).interstitialAd != null) {
             ref.read(interstitialAdProvider.notifier).showAd();
           } else {
            _logger.w('InterstitialAdManager: Ad (already loaded case) was no longer loaded or null when showAd was about to be called.');
           }
        });
      }

      if (next.isLoading) {
        _logger.i('InterstitialAdManager: Ad is loading...');
      }
      if (next.error != null) {
        _logger.e('InterstitialAdManager: Ad error state: ${next.error}');
      }
    });

    // This widget itself doesn't render anything visible for the interstitial ad,
    // as the ad is a full-screen overlay. It could return a SizedBox.shrink()
    // or a small indicator if desired for debugging or specific UI needs.
    // For now, let's just return an empty container.
    return const SizedBox.shrink();
  }
}
