import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ingredio/core/utils/app_theme.dart';
import 'package:ingredio/data/local/hive_database.dart';
import 'package:ingredio/domain/entities/recipe.dart';
import 'package:ingredio/di/service_locator.dart';
import 'package:ingredio/presentation/providers/hive_database_provider.dart';

class MockHiveDatabase extends Mock implements HiveDatabase {}

bool _fallbacksRegistered = false;

Recipe testRecipe({
  String id = '1',
  String name = 'Algerian Carrots',
  int matchCount = 2,
}) {
  return Recipe(
    id: id,
    name: name,
    thumbnail: '',
    ingredients: const ['Water', 'Carrots', 'Olive Oil'],
    matchedIngredients: const ['Carrots', 'Olive Oil'],
    matchCount: matchCount,
    instructions: 'Prep the vegetables. Cook until tender. Serve warm.',
    category: 'Side',
    youtubeLink: '',
    measures: const ['1 cup', '2 lbs', '2 tbsp'],
  );
}

MockHiveDatabase registerMockHive({
  List<String> selectedIngredients = const ['Carrots', 'Olive Oil'],
  Map<String, int> quantities = const {'Carrots': 2, 'Olive Oil': 1},
  List<Recipe> favorites = const [],
}) {
  if (!_fallbacksRegistered) {
    registerFallbackValue(testRecipe(id: 'fallback', name: 'Fallback'));
    _fallbacksRegistered = true;
  }

  final hiveDatabase = MockHiveDatabase();
  when(() => hiveDatabase.loadSelectedIngredients())
      .thenReturn(selectedIngredients);
  when(() => hiveDatabase.loadIngredientQuantities()).thenReturn(quantities);
  when(() => hiveDatabase.getFavorites()).thenReturn(favorites);
  when(() => hiveDatabase.saveSelectedIngredients(any()))
      .thenAnswer((_) async {});
  when(() => hiveDatabase.saveIngredientQuantity(any(), any()))
      .thenAnswer((_) async {});
  when(() => hiveDatabase.removeIngredientQuantity(any()))
      .thenAnswer((_) async {});
  when(() => hiveDatabase.addFavorite(any())).thenAnswer((_) async {});
  when(() => hiveDatabase.removeFavorite(any())).thenAnswer((_) async {});
  when(() => hiveDatabase.removeCachedRecipe(any())).thenAnswer((_) async {});

  if (getIt.isRegistered<HiveDatabase>()) {
    getIt.unregister<HiveDatabase>();
  }
  getIt.registerSingleton<HiveDatabase>(hiveDatabase);
  return hiveDatabase;
}

Future<void> resetGetIt() async {
  await getIt.reset();
}

Widget testApp(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      hiveDatabaseProvider.overrideWithValue(getIt<HiveDatabase>()),
      ...overrides,
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: child,
    ),
  );
}
