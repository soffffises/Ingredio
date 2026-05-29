import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IngredientIconData {
  final IconData icon;
  final String category;

  const IngredientIconData(this.icon, this.category);
}

class IngredientIcons {
  static IngredientIconData forName(String ingredient) {
    final value = ingredient.toLowerCase();

    if (_containsAny(value, ['chicken', 'turkey', 'duck'])) {
      return const IngredientIconData(
          FontAwesomeIcons.drumstickBite, 'Poultry');
    }
    if (_containsAny(
        value, ['beef', 'pork', 'lamb', 'bacon', 'ham', 'sausage'])) {
      return const IngredientIconData(FontAwesomeIcons.bacon, 'Protein');
    }
    if (_containsAny(
        value, ['salmon', 'fish', 'tuna', 'shrimp', 'prawn', 'cod'])) {
      return const IngredientIconData(FontAwesomeIcons.fish, 'Seafood');
    }
    if (_containsAny(value, ['egg'])) {
      return const IngredientIconData(FontAwesomeIcons.egg, 'Dairy & Eggs');
    }
    if (_containsAny(value, ['milk', 'cheese', 'cream', 'yogurt', 'butter'])) {
      return const IngredientIconData(FontAwesomeIcons.cheese, 'Dairy');
    }
    if (_containsAny(value,
        ['black pepper', 'white pepper', 'cumin', 'paprika', 'cinnamon', 'spice'])) {
      return const IngredientIconData(FontAwesomeIcons.mortarPestle, 'Spices');
    }
    if (_containsAny(value,
        ['apple', 'banana', 'berry', 'lemon', 'lime', 'orange', 'mango'])) {
      return const IngredientIconData(FontAwesomeIcons.appleWhole, 'Fruit');
    }
    if (_containsAny(value, ['bean', 'lentil', 'pea'])) {
      return const IngredientIconData(FontAwesomeIcons.seedling, 'Legumes');
    }
    if (_containsAny(value, [
      'tomato',
      'potato',
      'onion',
      'garlic',
      'carrot',
      'pepper',
      'lettuce',
      'kale',
      'spinach',
      'asparagus',
      'aubergine',
      'avocado',
      'basil'
    ])) {
      return const IngredientIconData(FontAwesomeIcons.carrot, 'Produce');
    }
    if (_containsAny(
        value, ['pasta', 'rice', 'flour', 'bread', 'noodle', 'powder'])) {
      return const IngredientIconData(FontAwesomeIcons.wheatAwn, 'Pantry');
    }
    if (_containsAny(value, ['oil', 'vinegar', 'sauce', 'mustard', 'honey'])) {
      return const IngredientIconData(
          FontAwesomeIcons.bottleDroplet, 'Condiments');
    }
    if (_containsAny(value, ['salt'])) {
      return const IngredientIconData(FontAwesomeIcons.mortarPestle, 'Spices');
    }
    if (_containsAny(value, ['chocolate', 'sugar', 'syrup', 'treacle'])) {
      return const IngredientIconData(FontAwesomeIcons.cookieBite, 'Sweet');
    }

    return const IngredientIconData(FontAwesomeIcons.bowlFood, 'Ingredient');
  }

  static bool _containsAny(String value, List<String> tokens) {
    return tokens.any(value.contains);
  }
}
