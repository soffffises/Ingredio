import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ingredio/presentation/screens/register_screen.dart';

import 'screen_test_helpers.dart';

void main() {
  testWidgets('Register screen renders onboarding copy', (tester) async {
    await tester.pumpWidget(
      testApp(const RegisterScreen()),
    );

    expect(find.text('Welcome to Ingredio'), findsOneWidget);
    expect(
      find.text('Choose how the app should look, then enter your name.'),
      findsOneWidget,
    );
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(
      find.widgetWithText(SegmentedButton<ThemeMode>, 'System'),
      findsOneWidget,
    );
    expect(find.text('Start'), findsOneWidget);
  });
}
