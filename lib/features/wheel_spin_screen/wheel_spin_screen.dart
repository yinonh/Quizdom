import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:trivia/core/common_widgets/background.dart';
import 'package:trivia/core/common_widgets/custom_drawer.dart';
import 'package:trivia/core/common_widgets/user_app_bar.dart';
import 'dart:async';

import 'package:trivia/core/constants/app_constant.dart';

class WheelSpinScreen extends StatefulWidget {
  const WheelSpinScreen({super.key});
  static const routeName = '/wheel-spin';

  @override
  _WheelSpinScreenState createState() => _WheelSpinScreenState();
}

class _WheelSpinScreenState extends State<WheelSpinScreen> {
  bool isSpinning = false;
  // Changed to broadcast StreamController
  final StreamController<int> _controller = StreamController<int>.broadcast();
  int _selectedValue = 0;

  final List<WheelItem> items = [
    WheelItem(coins: 100, backgroundColor: AppConstant.primaryColor),
    WheelItem(coins: 0, backgroundColor: AppConstant.secondaryColor),
    WheelItem(coins: 50, backgroundColor: AppConstant.onPrimaryColor),
    WheelItem(coins: 0, backgroundColor: AppConstant.highlightColor),
    WheelItem(coins: 200, backgroundColor: AppConstant.softHighlightColor),
    WheelItem(coins: 0, backgroundColor: AppConstant.primaryColor),
    WheelItem(coins: 75, backgroundColor: AppConstant.onPrimaryColor),
    WheelItem(coins: 150, backgroundColor: AppConstant.highlightColor),
  ];

  @override
  void initState() {
    super.initState();
    // Listen to the stream and update _selectedValue
    _controller.stream.listen((value) {
      _selectedValue = value;
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _onSpinEnd() {
    setState(() {
      isSpinning = false;
    });

    // Use the stored _selectedValue instead of accessing the stream again
    if (items[_selectedValue].coins > 0) {
      _showWinDialog(items[_selectedValue].coins);
    } else {
      _showBetterLuckDialog();
    }
  }

  void _showWinDialog(int coins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: AppConstant.goldColor,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              'Congratulations! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstant.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You won $coins coins!',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Awesome!'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showBetterLuckDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_neutral,
              color: AppConstant.secondaryColor,
              size: 50,
            ),
            SizedBox(height: 16),
            Text(
              'Better luck next time!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstant.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Keep playing to win coins!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Try Again'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserAppBar(
        prefix: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      drawer: const CustomDrawer(),
      body: CustomBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Spin & Win!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppConstant.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Try your luck to win coins!',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppConstant.highlightColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FortuneWheel(
                            selected: _controller.stream,
                            animateFirst: false,
                            onAnimationEnd: _onSpinEnd,
                            items: items.map((item) {
                              return FortuneItem(
                                style: FortuneItemStyle(
                                  color: item.backgroundColor,
                                  borderWidth: 2,
                                  borderColor: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    item.coins > 0
                                        ? '${item.coins} coins'
                                        : 'Try Again',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: isSpinning
                        ? null
                        : () {
                            setState(() {
                              isSpinning = true;
                            });
                            _controller.add(Random().nextInt(items.length));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstant.onPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isSpinning ? 'Spinning...' : 'SPIN NOW!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WheelItem {
  final int coins;
  final Color backgroundColor;

  WheelItem({
    required this.coins,
    required this.backgroundColor,
  });
}
