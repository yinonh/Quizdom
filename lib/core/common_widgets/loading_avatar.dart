import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/custom_clipper.dart';
import 'package:trivia/core/utils/fluttermoji/fluttermoji_provider.dart';
import 'package:trivia/core/utils/size_config.dart';

class LoadingAvatar extends ConsumerStatefulWidget {
  final double radius;
  final double progress;

  const LoadingAvatar({
    this.radius = 42,
    this.progress = 0,
    super.key,
  });

  @override
  ConsumerState<LoadingAvatar> createState() => _LoadingAvatarState();
}

class _LoadingAvatarState extends ConsumerState<LoadingAvatar>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final Random _random = Random();
  Map<String, int> _currentOptions = {
    'topType': 0,
    'skinColor': 0,
    'eyebrowType': 0,
    'facialHairType': 0,
    'eyeType': 0,
    'clotheType': 0,
    'accessoriesType': 0,
    'mouthType': 0,
    'graphicType': 0,
    'facialHairColor': 0,
    'style': 0,
    'hairColor': 0,
    'clotheColor': 0,
  };

  final Map<String, int> _maxValues = {
    'topType': 32,
    'skinColor': 5,
    'eyebrowType': 11,
    'facialHairType': 4,
    'eyeType': 11,
    'clotheType': 8,
    'accessoriesType': 6,
    'mouthType': 10,
    'facialHairColor': 8,
    'graphicType': 0,
    'style': 0,
    'hairColor': 8,
    'clotheColor': 11,
  };

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Create pulse animation
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start timer to change avatar every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _randomizeAvatar();
      });
    });
  }

  void _randomizeAvatar() {
    _maxValues.forEach((key, maxValue) {
      if (maxValue > 0) {
        _currentOptions[key] = _random.nextInt(maxValue + 1);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Progress indicator
        SizedBox(
          width: calcWidth(widget.radius * 2.1),
          height: calcWidth(widget.radius * 2.1),
          child: CircularProgressIndicator(
            strokeWidth: 6.0,
            value: widget.progress,
            color: AppConstant.onPrimaryColor,
            backgroundColor: AppConstant.onPrimaryColor.withOpacity(0.2),
          ),
        ),

        // Pulsing loading indicator
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: calcWidth(widget.radius * 2.3),
                height: calcWidth(widget.radius * 2.3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppConstant.onPrimaryColor.withOpacity(0.3),
                    width: 2.0,
                  ),
                ),
              ),
            );
          },
        ),

        // Animated avatar
        ClipPath(
          clipper: HalfCircleClipper(),
          child: CircleAvatar(
            radius: calcWidth(widget.radius),
            backgroundColor: AppConstant.softHighlightColor,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: SvgPicture.string(
                ref
                    .read(fluttermojiNotifierProvider.notifier)
                    .getFluttermojiFromOptions(_currentOptions),
                key: ValueKey(_currentOptions.toString()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
