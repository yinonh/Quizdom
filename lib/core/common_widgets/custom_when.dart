import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';

extension AsyncValueUI<T> on AsyncValue<T> {
  /// Custom when method with default loading and error handling
  Widget customWhen({
    required Widget Function(T data) data,
    Widget Function(Object error, StackTrace? stackTrace)? error,
    Widget Function()? loading,
  }) {
    return when(
      data: data,
      loading: () => loading?.call() ?? const DefaultLoadingWidget(),
      error: (e, st) =>
          error?.call(e, st) ?? DefaultErrorWidget(error: e, stackTrace: st),
    );
  }
}

/// Default loading widget to use when no custom one is provided
class DefaultLoadingWidget extends StatelessWidget {
  const DefaultLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppConstant.primaryColor,
      ),
    );
  }
}

/// Default error widget to use when no custom one is provided,
/// inspired by the NoInternetScreen design but using icons
class DefaultErrorWidget extends StatefulWidget {
  final Object error;
  final StackTrace? stackTrace;

  const DefaultErrorWidget({
    super.key,
    required this.error,
    this.stackTrace,
  });

  @override
  State<DefaultErrorWidget> createState() => _DefaultErrorWidgetState();
}

class _DefaultErrorWidgetState extends State<DefaultErrorWidget> {
  // Helper method to provide user-friendly error messages
  String _getErrorTitle(Object error) {
    if (error.toString().contains('connection refused') ||
        error.toString().contains('SocketException') ||
        error.toString().contains('timed out')) {
      return 'No Internet Connection';
    } else if (error.toString().contains('404')) {
      return 'Content Not Found';
    } else if (error.toString().contains('401') ||
        error.toString().contains('403')) {
      return 'Access Denied';
    } else if (error.toString().contains('500')) {
      return 'Server Error';
    }

    // Default message for other types of errors
    return 'Oops! Something went wrong';
  }

  String _getErrorMessage(Object error) {
    if (error.toString().contains('connection refused') ||
        error.toString().contains('SocketException') ||
        error.toString().contains('timed out')) {
      return 'Please check your internet connection and try again.';
    } else if (error.toString().contains('404') ||
        error.toString().contains('not found')) {
      return 'The content you are looking for could not be found.';
    } else if (error.toString().contains('401') ||
        error.toString().contains('403') ||
        error.toString().contains('unauthorized')) {
      return 'You might need to sign in again to continue.';
    } else if (error.toString().contains('500')) {
      return 'Our servers are experiencing issues. Please try again later.';
    } else if (error.toString().contains('format')) {
      return 'There was a problem processing the data.';
    }

    // Default message for other types of errors
    return 'An unexpected error occurred. Please try again.';
  }

  IconData _getErrorIcon(Object error) {
    if (error.toString().contains('connection refused') ||
        error.toString().contains('SocketException') ||
        error.toString().contains('timed out')) {
      return Icons.wifi_off_rounded;
    } else if (error.toString().contains('404')) {
      return Icons.search_off_rounded;
    } else if (error.toString().contains('401') ||
        error.toString().contains('403')) {
      return Icons.lock_rounded;
    } else if (error.toString().contains('500')) {
      return Icons.cloud_off_rounded;
    }

    // Default icon for other errors
    return Icons.error_rounded;
  }

  void _retryOperation() async {
    goRoute(CategoriesScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final String errorTitle = _getErrorTitle(widget.error);
    final String errorMessage = _getErrorMessage(widget.error);
    final IconData errorIcon = _getErrorIcon(widget.error);

    return Container(
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
                  width: calcWidth(150),
                  height: calcWidth(150),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        AppConstant.softHighlightColor.withValues(alpha: 0.3),
                  ),
                ),
                Icon(
                  errorIcon,
                  size: calcWidth(80),
                  color: AppConstant.white,
                ),
              ],
            ),
            SizedBox(height: calcHeight(24)),
            // Title text
            Text(
              errorTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: calcHeight(16)),
            // Subtitle text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: calcWidth(40)),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            // Debug info (only in debug mode)
            if (kDebugMode) ...[
              SizedBox(height: calcHeight(16)),
              Container(
                margin: EdgeInsets.symmetric(horizontal: calcWidth(40)),
                padding: EdgeInsets.all(calcWidth(16)),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Information:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: calcHeight(8)),
                    Text(
                      widget.error.toString(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: calcHeight(32)),
            // Retry button with loading state
            ElevatedButton(
              onPressed: _retryOperation,
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
              child: const Text(
                'Back Home',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
