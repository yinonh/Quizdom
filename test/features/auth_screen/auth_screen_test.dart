import 'package:Quizdom/features/auth_screen/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AuthScreen shows login and guest buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    expect(find.text('Login with Email'), findsOneWidget);
    expect(find.text('Login as Guest'), findsOneWidget);
  });
}
