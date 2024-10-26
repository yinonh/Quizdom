import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: fluttermojiState.when(
        data: (state) {
          if (state.fluttermoji.isEmpty) {
            return const CupertinoActivityIndicator();
          }
          return SvgPicture.string(
            state.fluttermoji,
            height: radius * 1.6,
            semanticsLabel: "Your Fluttermoji",
            placeholderBuilder: (context) => const Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        },
        loading: () => const CupertinoActivityIndicator(),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
