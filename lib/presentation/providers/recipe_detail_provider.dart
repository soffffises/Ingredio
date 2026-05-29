import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/domain/usecases/get_recipe_details.dart';
import 'package:ingredio/di/service_locator.dart';

final recipeDetailProvider =
    FutureProvider.family((ref, String recipeId) async {
  final getRecipeDetails = getIt<GetRecipeDetails>();
  return await getRecipeDetails(recipeId);
});
