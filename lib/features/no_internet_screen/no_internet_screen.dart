import 'package:flutter/material.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off,
                size: 100, color: AppConstant.primaryColor.toColor()),
            const SizedBox(height: 20),
            const Text(
              'No internet connection available.',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
