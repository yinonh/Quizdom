import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/providers/user_provider.dart';

class UserCoins extends ConsumerStatefulWidget {
  const UserCoins({super.key});

  @override
  ConsumerState<UserCoins> createState() => _UserCoinsState();
}

class _UserCoinsState extends ConsumerState<UserCoins>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int? _latestValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize animation with current value
    final initialValue = ref.read(authProvider).currentUser.coins;
    _latestValue = initialValue;
    _animation = IntTween(
      begin: initialValue,
      end: initialValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOutQuad),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation(int end) {
    // Stop any ongoing animation
    _controller.stop();

    final begin = _latestValue ?? end;
    _latestValue = end;

    setState(() {
      _animation = IntTween(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutQuad),
      ));
    });

    // Reset and start the animation
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final currentCoins = ref.watch(authProvider).currentUser.coins;

    // Start animation if value changed
    if (_latestValue != currentCoins) {
      _startAnimation(currentCoins);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          Strings.coinsIcon,
          height: calcHeight(30),
        ),
        SizedBox(width: calcWidth(5)),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Use the exact end value when animation completes
            final displayValue =
                _controller.isCompleted ? _latestValue! : _animation.value;

            return Text(
              displayValue.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }
}
