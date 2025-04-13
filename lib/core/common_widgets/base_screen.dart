import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_progress_indicator.dart';
import 'dart:ui';

import 'package:trivia/core/common_widgets/user_coins.dart';
import 'package:trivia/core/common_widgets/user_resources_dialog.dart';
import 'package:trivia/core/constants/app_constant.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class BaseScreen extends ConsumerWidget {
  final Widget child;

  const BaseScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          UserResourcesDialog.show(context);
        },
        backgroundColor: AppConstant.primaryColor,
        shape: const CircleBorder(),
        child: const UserCoins(),
      ),
      resizeToAvoidBottomInset: false,
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
