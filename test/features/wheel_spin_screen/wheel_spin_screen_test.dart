import 'package:Quizdom/features/wheel_spin_screen/wheel_spin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WheelSpinScreen shows the wheel', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WheelSpinScreen(),
        ),
      ),
    );

    expect(find.text('Spin the Wheel'), findsOneWidget);
    // This is a placeholder for the actual wheel.
    // We will need to mock the data to test this properly.
    expect(find.byType(FortuneWheel), findsOneWidget);
  });
}
