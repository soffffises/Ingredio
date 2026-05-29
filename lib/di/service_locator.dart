import 'package:get_it/get_it.dart';
import 'package:ingredio/data/api/api_client.dart';
import 'package:ingredio/data/api/mealdb_service.dart';
import 'package:ingredio/data/api/connectivity_service.dart';
import 'package:ingredio/data/local/hive_database.dart';
import 'package:ingredio/data/repositories/recipes_repository.dart';
import 'package:ingredio/data/repositories/recipe_details_repository.dart';
import 'package:ingredio/domain/repositories/i_recipes_repository.dart';
import 'package:ingredio/domain/repositories/i_recipe_details_repository.dart';
import 'package:ingredio/domain/usecases/get_recipes_by_ingredients.dart';
import 'package:ingredio/domain/usecases/get_recipe_details.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final hiveDatabase = HiveDatabase();
  await hiveDatabase.init();
  getIt.registerSingleton<HiveDatabase>(hiveDatabase);

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(Connectivity()));
  getIt.registerLazySingleton<MealDbService>(() => MealDbService(
        getIt<ApiClient>(),
        getIt<HiveDatabase>(),
      ));
  getIt.registerLazySingleton<IRecipesRepository>(() => RecipesRepository(
        mealDbService: getIt<MealDbService>(),
        hiveDatabase: getIt<HiveDatabase>(),
      ));
  getIt.registerLazySingleton<IRecipeDetailsRepository>(
      () => RecipeDetailsRepository(
            mealDbService: getIt<MealDbService>(),
            hiveDatabase: getIt<HiveDatabase>(),
          ));
  getIt.registerFactory(
      () => GetRecipesByIngredients(getIt<IRecipesRepository>()));
  getIt.registerFactory(
      () => GetRecipeDetails(getIt<IRecipeDetailsRepository>()));
}
