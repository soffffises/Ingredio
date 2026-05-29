import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ingredio/presentation/providers/connectivity_provider.dart';
import 'package:ingredio/presentation/providers/recipes_provider.dart';
import 'package:ingredio/presentation/screens/recipes_list_screen.dart';

import 'screen_test_helpers.dart';

void main() {
  tearDown(resetGetIt);

  testWidgets('renders discover screen with featured and recommended recipes',
      (tester) async {
    registerMockHive();
    final recipes = [
      testRecipe(id: '1', name: 'Algerian Carrots', matchCount: 2),
      testRecipe(id: '2', name: 'Beef Mechado', matchCount: 1),
      testRecipe(id: '3', name: 'Pasta Bowl', matchCount: 1),
    ];

    await tester.pumpWidget(
      testApp(
        const RecipesListScreen(),
        overrides: [
          connectivityProvider.overrideWith((ref) async => true),
          recipesProvider.overrideWith((ref) async => recipes),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready to cook?'), findsOneWidget);
    expect(find.textContaining('We found 3 recipes'), findsOneWidget);
    expect(find.text('Algerian Carrots'), findsOneWidget);
    expect(find.text('Recommended for you'), findsOneWidget);
    expect(find.text('Beef Mechado'), findsOneWidget);
  });

  testWidgets('filters recipes by search query', (tester) async {
    registerMockHive();
    final recipes = [
      testRecipe(id: '1', name: 'Algerian Carrots', matchCount: 2),
      testRecipe(id: '2', name: 'Beef Mechado', matchCount: 1),
    ];

    await tester.pumpWidget(
      testApp(
        const RecipesListScreen(),
        overrides: [
          connectivityProvider.overrideWith((ref) async => true),
          recipesProvider.overrideWith((ref) async => recipes),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'beef');
    await tester.pumpAndSettle();

    expect(find.text('Beef Mechado'), findsOneWidget);
    expect(find.text('Algerian Carrots'), findsNothing);
  });
}
