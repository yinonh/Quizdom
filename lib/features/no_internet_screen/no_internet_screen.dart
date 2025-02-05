import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isLoading = false;

  void _retryConnection() async {
    setState(() => _isLoading = true);

    // Simulate a delay of 2 seconds
    await Future.delayed(const Duration(seconds: 7));

    if (!mounted) return;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstant.primaryColor,
                AppConstant.highlightColor,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular background for icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: calcWidth(200),
                      height: calcWidth(200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstant.softHighlightColor
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    Icon(
                      Icons.wifi_off,
                      size: calcWidth(100),
                      color: Colors.white,
                    ),
                  ],
                ),

                SizedBox(height: calcHeight(30)),

                // Title text
                const Text(
                  Strings.noInternet,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                SizedBox(height: calcHeight(16)),

                // Subtitle text
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: calcWidth(40)),
                  child: const Text(
                    Strings.pleaseCheckInternetAndTryAgain,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

                SizedBox(height: calcHeight(40)),

                // Retry button with loading state
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _retryConnection, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstant.onPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: calcWidth(40),
                      vertical: calcHeight(15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          Strings.retryConnection,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
