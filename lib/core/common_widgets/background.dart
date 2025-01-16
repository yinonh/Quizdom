import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget child;

  const CustomBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.orangeAccent.withValues(alpha:0.1),
            Colors.white.withValues(alpha:0.1),
            Colors.white.withValues(alpha:0.1),
            Colors.purpleAccent.withValues(alpha:0.1),
          ],
          stops: const [
            0,
            0.4,
            0.6,
            1
          ], // Adjust stops to make white more dominant
        ),
      ),
      child: child,
    );
  }
}
