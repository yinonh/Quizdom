import 'package:Quizdom/features/quiz_screen/solo_quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('QuizScreen shows a question and answers', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SoloQuizScreen(
            categoryId: '9',
            categoryName: 'General Knowledge',
          ),
        ),
      ),
    );

    // This is a placeholder for the actual question and answers.
    // We will need to mock the data to test this properly.
    expect(find.text('General Knowledge'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
