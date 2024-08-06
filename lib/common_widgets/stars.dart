import 'package:flutter/material.dart';

class UserStars extends StatelessWidget {
  const UserStars({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => const Icon(Icons.star, color: Color(0xFFFFD700)),
      ),
    );
  }
}
