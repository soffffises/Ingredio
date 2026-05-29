import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/presentation/screens/register_screen.dart';

void main() {
  testWidgets('Register screen renders onboarding copy', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to Ingredio'), findsOneWidget);
    expect(find.text('Enter your name to continue.'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });
}
