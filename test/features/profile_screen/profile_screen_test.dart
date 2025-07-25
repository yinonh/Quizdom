import 'package:Quizdom/features/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProfileScreen shows user information', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    // This is a placeholder for the actual user information.
    // We will need to mock the data to test this properly.
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });
}
