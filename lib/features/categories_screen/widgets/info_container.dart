import 'package:flutter/material.dart';

class InfoContainer extends StatelessWidget {
  final String text;

  const InfoContainer({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        color: Colors.grey[200],
        child: Center(child: Text(text)),
      ),
    );
  }
}
