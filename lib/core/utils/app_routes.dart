class AppRoutes {
  static const splash = '/';
  static const register = '/register';
  static const main = '/main';
  static const recipes = '/recipes';
  static const recipeDetail = '/recipe-detail';
  static const settings = '/settings';
}

class RecipeDetailRouteArgs {
  final String recipeId;

  const RecipeDetailRouteArgs({required this.recipeId});
}
