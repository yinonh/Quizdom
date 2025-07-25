import 'package:Quizdom/features/results_screen/solo_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ResultsScreen shows the score', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SoloResultsScreen(
            score: 0,
            questions: [],
          ),
        ),
      ),
    );

    expect(find.text('Your Score'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
