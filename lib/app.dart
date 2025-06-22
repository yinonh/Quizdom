import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_progress_indicator.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/global_providers/auth_providers.dart';
import 'package:trivia/core/navigation/router.dart';
import 'package:trivia/core/utils/size_config.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);

    // Watch unified auth state instead of separate initialization
    final authState = ref.watch(unifiedAuthProvider);

    // Get the router
    final router = ref.watch(routerProvider);

    return authState.when(
      data: (state) {
        // Show loading if not initialized yet
        if (!state.isInitialized) {
          return MaterialApp(
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
          );
        }

        // Show error if there's an auth error
        if (state.error != null) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstant.primaryColor,
              ),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Authentication Error: ${state.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Trigger a refresh of the auth state
                        ref.invalidate(unifiedAuthProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Normal app with router
        return MaterialApp.router(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstant.primaryColor,
            ),
            useMaterial3: true,
          ),
          routerConfig: router,
        );
      },
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Trigger a refresh of the auth state
                    ref.invalidate(unifiedAuthProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
