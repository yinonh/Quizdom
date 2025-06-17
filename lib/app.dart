import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/common_widgets/custom_progress_indicator.dart';
import 'core/constants/app_constant.dart';
import 'core/navigation/router.dart';
import 'core/utils/size_config.dart';
import 'data/providers/app_initialization_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);

    // Watch initialization state
    final initialization = ref.watch(appInitializationProvider);

    // Get the router
    final router = ref.watch(routerProvider);

    return initialization.when(
      data: (_) => MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstant.primaryColor,
          ),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
      loading: () => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstant.primaryColor,
          ),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(child: CustomProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstant.primaryColor,
          ),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
