import 'package:flutter/material.dart';

import 'customProgressIndicator.dart';

class LoadingViewOverlay extends StatelessWidget {
  final int? overlayAlpha;

  const LoadingViewOverlay({super.key, this.overlayAlpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: Colors.grey.withAlpha(overlayAlpha ?? 50),
      child: const Center(
        child: CustomProgressIndicator(),
      ),
    );
  }
}
