import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_progress_indicator.dart';
import 'dart:ui';

final loadingProvider = StateProvider<bool>((ref) => false);

class BaseScreen extends ConsumerWidget {
  final Widget child;
  final Widget? actionButton;

  const BaseScreen({super.key, required this.child, this.actionButton});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: actionButton,
      body: Stack(
        alignment: Alignment.center,
        children: [
          child,
          if (isLoading)
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
