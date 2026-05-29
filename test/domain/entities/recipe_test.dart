import 'package:flutter_test/flutter_test.dart';
import 'package:ingredio/domain/entities/recipe.dart';

void main() {
  test('Recipe fromJson/toJson round trip preserves data', () {
    final json = {
      'id': '52772',
      'name': 'Teriyaki Chicken Casserole',
      'thumbnail':
          'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      'ingredients': ['Chicken', 'Soy Sauce', 'Brown Sugar'],
      'matchCount': 2,
      'matchedIngredients': ['Chicken', 'Soy Sauce'],
      'instructions': 'Mix and bake.',
      'category': 'Chicken',
      'youtubeLink': 'https://www.youtube.com/watch?v=4aZr5hZXP_s',
      'measures': ['1 lb', '3 tbsp', '1/4 cup'],
    };

    final recipe = Recipe.fromJson(json);

    expect(recipe.id, '52772');
    expect(recipe.name, 'Teriyaki Chicken Casserole');
    expect(recipe.toJson(), equals(json));
  });
}
