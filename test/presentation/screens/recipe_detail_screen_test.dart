import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ingredio/presentation/providers/connectivity_provider.dart';
import 'package:ingredio/presentation/providers/recipe_detail_provider.dart';
import 'package:ingredio/presentation/screens/recipe_detail_screen.dart';

import 'screen_test_helpers.dart';

void main() {
  tearDown(resetGetIt);

  testWidgets('renders hero detail content, ingredients and steps',
      (tester) async {
    registerMockHive();
    final recipe = testRecipe();

    await tester.pumpWidget(
      testApp(
        RecipeDetailScreen(recipeId: recipe.id),
        overrides: [
          connectivityProvider.overrideWith((ref) async => true),
          recipeDetailProvider.overrideWith(
            (ref, recipeId) async => recipe,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Algerian Carrots'), findsOneWidget);
    expect(find.text('Ingredients Needed'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    expect(find.text('Carrots'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Step-by-Step'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Step-by-Step'), findsOneWidget);
    expect(find.text('Start Cooking'), findsOneWidget);
  });

  testWidgets('shows retry state when recipe detail loading fails',
      (tester) async {
    registerMockHive();

    await tester.pumpWidget(
      testApp(
        const RecipeDetailScreen(recipeId: 'missing'),
        overrides: [
          connectivityProvider.overrideWith((ref) async => true),
          recipeDetailProvider.overrideWith(
            (ref, recipeId) async => throw Exception('missing recipe'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
