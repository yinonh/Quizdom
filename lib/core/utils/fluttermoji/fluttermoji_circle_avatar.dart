import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Quizdom/core/network/server.dart';
import 'package:Quizdom/core/utils/custom_clipper.dart';

import 'fluttermoji_provider.dart';

/// This widget renders the Fluttermoji of the user on screen
///
/// Accepts a [radius] which defaults to 75.0
/// and a [backgroundColor] which defaults to blueAccent
///
/// Advises the users to set up their Fluttermoji first to avoid unexpected issues.
class FluttermojiCircleAvatar extends ConsumerWidget {
  final double radius;
  final Color? backgroundColor;

  const FluttermojiCircleAvatar({
    super.key,
    this.radius = 75.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fluttermojiState = ref.watch(fluttermojiNotifierProvider);

    return ClipPath(
      clipper: HalfCircleClipper(),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: fluttermojiState.when(
          data: (state) {
            if (state.fluttermoji.isEmpty) {
              logger.e("fluttermoji avatar is empty");
              return const CircularProgressIndicator();
            }
            return SvgPicture.string(
              state.fluttermoji,
              height: radius * 2.1,
              semanticsLabel: "Your Fluttermoji",
              placeholderBuilder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
