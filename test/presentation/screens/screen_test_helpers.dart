import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ingredio/core/utils/app_theme.dart';
import 'package:ingredio/data/local/hive_database.dart';
import 'package:ingredio/domain/entities/recipe.dart';
import 'package:ingredio/di/service_locator.dart';
import 'package:ingredio/presentation/providers/hive_database_provider.dart';
import 'package:ingredio/presentation/providers/theme_mode_provider.dart';

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
  final resolvedOverrides = <Override>[
    if (getIt.isRegistered<HiveDatabase>())
      hiveDatabaseProvider.overrideWithValue(getIt<HiveDatabase>()),
    themeModeProvider.overrideWith((ref) => _TestThemeModeNotifier()),
    ...overrides,
  ];

  return ProviderScope(
    overrides: resolvedOverrides,
    child: MaterialApp(
      theme: AppTheme.light,
      home: child,
    ),
  );
}

class _TestThemeModeNotifier extends ThemeModeNotifier {
  _TestThemeModeNotifier() : super(_FakeSharedPreferences());
}

class _FakeSharedPreferences implements SharedPreferences {
  final Map<String, Object> _values = {};

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  double? getDouble(String key) => _values[key] as double?;

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  List<String>? getStringList(String key) => _values[key] as List<String>?;

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<void> reload() async {}

  @override
  Set<String> getKeys() => _values.keys.toSet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
