import 'dart:math';

import 'package:flutter/material.dart';

class MultipleAnswerWidget extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(int) onAnswerSelected;

  const MultipleAnswerWidget({
    Key? key,
    required this.question,
    required this.options,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 25.0),
        ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            // Apply fade animation
            return FadeTransition(
              opacity: Tween<double>(
                begin: 0,
                end: 1,
              ).animate(
                CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
                ),
              ),
              child: GestureDetector(
                onTap: () => onAnswerSelected(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    options[index],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
