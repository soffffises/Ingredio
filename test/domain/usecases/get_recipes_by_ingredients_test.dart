import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantry_chef/domain/entities/recipe.dart';
import 'package:pantry_chef/domain/repositories/i_recipes_repository.dart';
import 'package:pantry_chef/domain/usecases/get_recipes_by_ingredients.dart';

class _MockRecipesRepository extends Mock implements IRecipesRepository {}

void main() {
  late _MockRecipesRepository repository;
  late GetRecipesByIngredients usecase;

  setUp(() {
    repository = _MockRecipesRepository();
    usecase = GetRecipesByIngredients(repository);
  });

  test('returns empty list without calling repository when input is empty',
      () async {
    final result = await usecase([]);

    expect(result, isEmpty);
    verifyNever(() => repository.getRecipesByIngredients(any(), any()));
  });

  test('removes duplicate ingredients and preserves only non-empty values',
      () async {
    final recipes = [
      Recipe(id: '1', name: 'Pasta', ingredients: const ['Pasta']),
    ];
    when(() => repository.getRecipesByIngredients(any(), true))
        .thenAnswer((_) async => recipes);

    final result = await usecase(
      ['Tomato', 'Tomato', '  ', 'Garlic'],
      onlyBasicInfo: true,
    );

    expect(result, recipes);
    verify(() => repository.getRecipesByIngredients(
          ['Tomato', 'Garlic'],
          true,
        )).called(1);
  });

  test('passes onlyBasicInfo flag through to repository', () async {
    when(() => repository.getRecipesByIngredients(any(), false))
        .thenAnswer((_) async => const []);

    await usecase(['Chicken'], onlyBasicInfo: false);

    verify(() => repository.getRecipesByIngredients(['Chicken'], false))
        .called(1);
  });
}
