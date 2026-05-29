import 'package:flutter_test/flutter_test.dart';
import 'package:ingredio/presentation/providers/connectivity_provider.dart';
import 'package:ingredio/presentation/providers/ingredients_list_provider.dart';
import 'package:ingredio/presentation/screens/ingredients_screen.dart';

import 'screen_test_helpers.dart';

void main() {
  tearDown(resetGetIt);

  testWidgets('renders pantry header, quick add and selected pantry items',
      (tester) async {
    registerMockHive();

    await tester.pumpWidget(
      testApp(
        const IngredientsScreen(),
        overrides: [
          connectivityProvider.overrideWith((ref) async => true),
          ingredientsListProvider.overrideWith(
            (ref) async => const ['Carrots', 'Olive Oil', 'Tomato', 'Garlic'],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Build your pantry'), findsOneWidget);
    expect(find.text('QUICK ADD'), findsOneWidget);
    expect(find.text('MY PANTRY'), findsOneWidget);
    expect(find.text('Carrots'), findsOneWidget);
    expect(find.text('Olive Oil'), findsWidgets);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('shows offline state when connectivity provider is false',
      (tester) async {
    registerMockHive();

    await tester.pumpWidget(
      testApp(
        const IngredientsScreen(),
        overrides: [
          connectivityProvider.overrideWith((ref) async => false),
          ingredientsListProvider.overrideWith((ref) async => const []),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No internet connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
