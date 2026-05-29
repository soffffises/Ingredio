import 'package:ingredio/domain/entities/recipe.dart';

abstract class IRecipeDetailsRepository {
  Future<Recipe> getRecipeDetails(String id);
}
