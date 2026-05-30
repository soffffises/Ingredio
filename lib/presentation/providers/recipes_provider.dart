import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/di/service_locator.dart';
import 'package:ingredio/data/api/connectivity_service.dart';
import 'package:ingredio/data/local/hive_database.dart';
import 'package:ingredio/domain/entities/recipe.dart';
import 'package:ingredio/domain/usecases/get_recipes_by_ingredients.dart';
import 'package:ingredio/presentation/providers/ingredients_provider.dart';

final recipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final ingredients = ref.watch(ingredientsProvider);
  final getRecipes = getIt<GetRecipesByIngredients>();
  final connectivityService = getIt<ConnectivityService>();
  final hiveDatabase = getIt<HiveDatabase>();

  if (ingredients.isEmpty) {
    return <Recipe>[];
  }

  final isConnected = await connectivityService.isConnected();
  if (!isConnected) {
    return hiveDatabase.getCachedRecipes();
  }

  return await getRecipes(
    ingredients,
    onlyBasicInfo: true,
  );
});
