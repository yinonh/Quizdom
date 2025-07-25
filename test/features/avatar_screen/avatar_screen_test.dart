import 'package:Quizdom/features/avatar_screen/avatar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AvatarScreen shows avatar customization options', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AvatarScreen(),
        ),
      ),
    );

    expect(find.text('Customize Avatar'), findsOneWidget);
    // This is a placeholder for the actual avatar customization options.
    // We will need to mock the data to test this properly.
    expect(find.byType(GridView), findsOneWidget);
  });
}
