import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantry_chef/domain/entities/recipe.dart';
import 'package:pantry_chef/domain/repositories/i_recipe_details_repository.dart';
import 'package:pantry_chef/domain/usecases/get_recipe_details.dart';

class _MockRecipeDetailsRepository extends Mock
    implements IRecipeDetailsRepository {}

void main() {
  late _MockRecipeDetailsRepository repository;
  late GetRecipeDetails usecase;

  setUp(() {
    repository = _MockRecipeDetailsRepository();
    usecase = GetRecipeDetails(repository);
  });

  test('throws ArgumentError when recipe id is empty', () async {
    expect(
      () => usecase(''),
      throwsA(isA<ArgumentError>()),
    );
    verifyNever(() => repository.getRecipeDetails(any()));
  });

  test('returns recipe details from repository', () async {
    final recipe = Recipe(
      id: '52772',
      name: 'Teriyaki Chicken',
      ingredients: const ['Chicken'],
      instructions: 'Cook chicken.',
    );
    when(() => repository.getRecipeDetails('52772'))
        .thenAnswer((_) async => recipe);

    final result = await usecase('52772');

    expect(result, recipe);
    verify(() => repository.getRecipeDetails('52772')).called(1);
  });
}
