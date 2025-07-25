import 'package:Quizdom/features/categories_screen/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.d-art';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CategoriesScreen shows a list of categories', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CategoriesScreen(),
        ),
      ),
    );

    expect(find.text('Categories'), findsOneWidget);
    // This is a placeholder for the actual categories.
    // We will need to mock the data to test this properly.
    expect(find.byType(ListView), findsOneWidget);
  });
}
