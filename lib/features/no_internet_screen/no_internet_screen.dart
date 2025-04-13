import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late final AnimationController _animationController;
  // Set the delay duration between loops
  final Duration delayDuration = const Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    // Listen for when the animation completes, then introduce a delay before restarting
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(delayDuration, () {
          if (mounted) {
            _animationController.reset();
            _animationController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _retryConnection() async {
    setState(() => _isLoading = true);

    // Simulate a delay (e.g., trying to reconnect)
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
                    Center(
                      child: SizedBox(
                        height: calcHeight(200),
                        width: calcWidth(200),
                        child: Lottie.asset(
                          Strings.noInternetAnimation,
                          controller: _animationController,
                          onLoaded: (composition) {
                            // Set the controller's duration to the animation duration and start playing.
                            _animationController.duration =
                                composition.duration;
                            _animationController.forward();
                          },
                        ),
                      ),
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
                  onPressed: _isLoading ? null : _retryConnection,
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
