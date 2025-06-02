import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/common_widgets/background.dart';
import 'package:trivia/core/common_widgets/custom_drawer.dart';
import 'package:trivia/core/common_widgets/user_app_bar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/app_routes.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/features/wheel_spin_screen/view_model/wheel_screen_manager.dart';
import 'package:trivia/features/wheel_spin_screen/widgets/lose_dialog.dart';
import 'package:trivia/features/wheel_spin_screen/widgets/win_dialog.dart';

class WheelSpinScreen extends ConsumerStatefulWidget {
  const WheelSpinScreen({super.key});

  static const routeName = AppRoutes.wheelSpinRouteName;

  @override
  _WheelSpinScreenState createState() => _WheelSpinScreenState();
}

class _WheelSpinScreenState extends ConsumerState<WheelSpinScreen> {
  bool isSpinning = false;

  // Changed to broadcast StreamController
  final StreamController<int> _controller = StreamController<int>.broadcast();
  int _selectedValue = 0;

  final List<WheelItem> items = [
    WheelItem(coins: 100, backgroundColor: AppConstant.primaryColor),
    WheelItem(coins: 5, backgroundColor: AppConstant.secondaryColor),
    WheelItem(coins: 0, backgroundColor: AppConstant.onPrimaryColor),
    WheelItem(coins: 20, backgroundColor: AppConstant.highlightColor),
    WheelItem(coins: 50, backgroundColor: AppConstant.primaryColor),
    WheelItem(coins: 0, backgroundColor: AppConstant.secondaryColor),
    WheelItem(coins: 10, backgroundColor: AppConstant.onPrimaryColor),
    WheelItem(coins: 0, backgroundColor: AppConstant.highlightColor),
    WheelItem(coins: 25, backgroundColor: AppConstant.primaryColor),
    WheelItem(coins: 0, backgroundColor: AppConstant.secondaryColor),
  ];

  @override
  void initState() {
    super.initState();
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
      ref
          .read(wheelScreenManagerProvider.notifier)
          .updateCoins(items[_selectedValue].coins - 10);
      _showWinDialog(items[_selectedValue].coins);
    } else {
      ref.read(wheelScreenManagerProvider.notifier).updateCoins(-10);
      _showBetterLuckDialog();
    }
  }

  void _showWinDialog(int coins) {
    WinDialogScreen.show(context, coins);
  }

  void _showBetterLuckDialog() {
    LoseDialogScreen.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final wheelState = ref.watch(wheelScreenManagerProvider);
    return Scaffold(
      appBar: UserAppBar(
        prefix: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () {
            context.goNamed(CategoriesScreen.routeName);
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
                  const Text(
                    Strings.spinAndWin,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppConstant.primaryColor,
                    ),
                  ),
                  const Text(
                    Strings.tryYourLuckWinCoins,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppConstant.highlightColor,
                    ),
                  ),
                  SizedBox(height: calcHeight(40)),
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
                                        ? '${item.coins} ${Strings.coins}'
                                        : Strings.noPrize,
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
                  SizedBox(height: calcHeight(40)),
                  ElevatedButton(
                    onPressed: isSpinning || wheelState.currentUser.coins < 10
                        ? null
                        : () {
                            setState(() {
                              isSpinning = true;
                            });
                            _controller.add(Random().nextInt(items.length));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstant.onPrimaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: calcWidth(40),
                        vertical: calcHeight(16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isSpinning
                          ? Strings.spinning
                          : "${Strings.spinNow} ${Strings.tenCoins}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: calcHeight(40)),
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
