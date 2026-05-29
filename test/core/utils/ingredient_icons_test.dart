import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pantry_chef/core/utils/ingredient_icons.dart';

void main() {
  test('maps poultry ingredients to poultry icon and category', () {
    final result = IngredientIcons.forName('Chicken Breast');

    expect(result.icon, FontAwesomeIcons.drumstickBite);
    expect(result.category, 'Poultry');
  });

  test('maps spices before generic produce pepper matching', () {
    final result = IngredientIcons.forName('Black Pepper');

    expect(result.icon, FontAwesomeIcons.mortarPestle);
    expect(result.category, 'Spices');
  });

  test('falls back for unknown ingredients', () {
    final result = IngredientIcons.forName('Mystery Root');

    expect(result.icon, FontAwesomeIcons.bowlFood);
    expect(result.category, 'Ingredient');
  });
}
