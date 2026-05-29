import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/data/local/hive_database.dart';
import 'package:ingredio/di/service_locator.dart';

final ingredientQuantitiesProvider =
    StateNotifierProvider<IngredientQuantitiesNotifier, Map<String, int>>(
        (ref) {
  return IngredientQuantitiesNotifier();
});

class IngredientQuantitiesNotifier extends StateNotifier<Map<String, int>> {
  IngredientQuantitiesNotifier() : super({}) {
    _loadQuantities();
  }

  final hiveDatabase = getIt<HiveDatabase>();

  int quantityFor(String ingredient) {
    return state[ingredient] ?? 1;
  }

  void ensureQuantity(String ingredient) {
    if (state.containsKey(ingredient)) return;
    _setQuantity(ingredient, 1);
  }

  void increment(String ingredient) {
    _setQuantity(ingredient, quantityFor(ingredient) + 1);
  }

  void decrement(String ingredient) {
    final nextQuantity = quantityFor(ingredient) - 1;
    if (nextQuantity < 1) return;
    _setQuantity(ingredient, nextQuantity);
  }

  void remove(String ingredient) {
    if (!state.containsKey(ingredient)) return;
    final nextState = Map<String, int>.from(state)..remove(ingredient);
    state = nextState;
    hiveDatabase.removeIngredientQuantity(ingredient);
  }

  void _setQuantity(String ingredient, int quantity) {
    final nextState = Map<String, int>.from(state)..[ingredient] = quantity;
    state = nextState;
    hiveDatabase.saveIngredientQuantity(ingredient, quantity);
  }

  void _loadQuantities() {
    state = hiveDatabase.loadIngredientQuantities();
  }
}
