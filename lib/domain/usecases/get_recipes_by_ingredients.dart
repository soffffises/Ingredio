import 'package:ingredio/domain/entities/recipe.dart';
import 'package:ingredio/domain/repositories/i_recipes_repository.dart';

class GetRecipesByIngredients {
  final IRecipesRepository repository;
  GetRecipesByIngredients(this.repository);
  Future<List<Recipe>> call(List<String> ingredients,
      {bool onlyBasicInfo = true}) async {
    if (ingredients.isEmpty) {
      return [];
    }

    final uniqueIngredients =
        ingredients.where((ing) => ing.trim().isNotEmpty).toSet().toList();
    return await repository.getRecipesByIngredients(
        uniqueIngredients, onlyBasicInfo);
  }
}
