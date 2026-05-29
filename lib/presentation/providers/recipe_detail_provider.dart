import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/domain/entities/recipe.dart';
import 'package:ingredio/domain/usecases/get_recipe_details.dart';
import 'package:ingredio/di/service_locator.dart';
import 'package:ingredio/data/api/connectivity_service.dart';
import 'package:ingredio/data/local/hive_database.dart';
import 'package:ingredio/core/utils/constants.dart';

final recipeDetailProvider =
    FutureProvider.family<Recipe, String>((ref, String recipeId) async {
  final getRecipeDetails = getIt<GetRecipeDetails>();
  final connectivityService = getIt<ConnectivityService>();
  final hiveDatabase = getIt<HiveDatabase>();

  final isConnected = await connectivityService.isConnected();
  if (!isConnected) {
    final cachedRecipe = await hiveDatabase.getCachedRecipe(recipeId);
    if (cachedRecipe != null) {
      return cachedRecipe;
    }
    throw Exception(Constants.noInternetConnection);
  }

  return await getRecipeDetails(recipeId);
});
