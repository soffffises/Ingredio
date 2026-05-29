import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/di/service_locator.dart';
import 'package:ingredio/domain/usecases/get_recipes_by_ingredients.dart';
import 'package:ingredio/presentation/providers/ingredients_provider.dart';

final recipesProvider = FutureProvider((ref) async {
  final ingredients = ref.watch(ingredientsProvider);
  final getRecipes = getIt<GetRecipesByIngredients>();
  return await getRecipes(
    ingredients,
    onlyBasicInfo: true,
  );
});
