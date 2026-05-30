import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/di/service_locator.dart';
import 'package:ingredio/data/api/mealdb_service.dart';
import 'package:ingredio/data/api/connectivity_service.dart';
import 'package:ingredio/data/local/hive_database.dart';

final ingredientsListProvider = FutureProvider<List<String>>((ref) async {
  final mealDbService = getIt<MealDbService>();
  final hiveDatabase = getIt<HiveDatabase>();
  final connectivityService = getIt<ConnectivityService>();

  List<String> cachedIngredients = await hiveDatabase.getCachedIngredients();
  if (cachedIngredients.isNotEmpty) {
    return cachedIngredients;
  }

  final isConnected = await connectivityService.isConnected();
  if (!isConnected) {
    return cachedIngredients;
  }

  try {
    final ingredients = await mealDbService.getIngredients();
    await hiveDatabase.cacheIngredients(ingredients);
    return ingredients;
  } catch (e) {
    throw Exception('Failed to load ingredients: $e');
  }
});
