import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantry_chef/presentation/providers/recipes_provider.dart';
import 'package:pantry_chef/presentation/screens/profile_screen.dart';

import 'screen_test_helpers.dart';

void main() {
  tearDown(resetGetIt);

  testWidgets('shows at most three favorite recipes on profile',
      (tester) async {
    final favorites = List.generate(
      4,
      (index) => testRecipe(
        id: '$index',
        name: 'Favorite Recipe $index',
        matchCount: index,
      ),
    );
    registerMockHive(favorites: favorites);

    await tester.pumpWidget(
      testApp(
        const ProfileScreen(),
        overrides: [
          recipesProvider.overrideWith((ref) async => const []),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Favorite Recipes'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Favorite Recipe 0'), findsOneWidget);
    expect(find.text('Favorite Recipe 1'), findsOneWidget);
    expect(find.text('Favorite Recipe 2'), findsOneWidget);
    expect(find.text('Favorite Recipe 3'), findsNothing);
  });

  testWidgets('can add, edit and delete collections', (tester) async {
    registerMockHive();

    await tester.pumpWidget(
      testApp(
        const ProfileScreen(),
        overrides: [
          recipesProvider.overrideWith((ref) async => const []),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('My Collections'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'Dinner Ideas');
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    expect(find.text('Dinner Ideas'), findsWidgets);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit collection').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Weekend Meals');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Dinner Ideas'), findsNothing);
    expect(find.text('Weekend Meals'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit collection').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Meals'), findsNothing);
  });

  testWidgets('can add and remove recipes inside a collection', (tester) async {
    final recipes = [
      testRecipe(id: 'recipe-a', name: 'Pasta Night', matchCount: 3),
      testRecipe(id: 'recipe-b', name: 'Rice Bowl', matchCount: 1),
    ];
    registerMockHive();

    await tester.pumpWidget(
      testApp(
        const ProfileScreen(),
        overrides: [
          recipesProvider.overrideWith((ref) async => recipes),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('My Collections'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'Dinner Ideas');
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dinner Ideas'));
    await tester.pumpAndSettle();

    expect(find.text('No recipes in this collection yet.'), findsOneWidget);

    await tester.tap(find.text('Add Recipe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pasta Night'));
    await tester.pumpAndSettle();

    expect(find.text('Dinner Ideas'), findsWidgets);
    expect(find.text('Pasta Night'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove from collection'));
    await tester.pumpAndSettle();

    expect(find.text('Pasta Night'), findsNothing);
    expect(find.text('No recipes in this collection yet.'), findsOneWidget);
  });
}
