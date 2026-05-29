import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pantry_chef/core/utils/app_theme.dart';
import 'package:pantry_chef/core/utils/constants.dart';
import 'package:pantry_chef/core/utils/ingredient_icons.dart';
import 'package:pantry_chef/presentation/providers/connectivity_provider.dart';
import 'package:pantry_chef/presentation/providers/ingredient_quantities_provider.dart';
import 'package:pantry_chef/presentation/providers/ingredients_list_provider.dart';
import 'package:pantry_chef/presentation/providers/ingredients_provider.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  static const int maxSelectedIngredients = 30;
  static const List<String> _quickAddIngredients = [
    'Tomato',
    'Egg',
    'Pasta',
    'Olive Oil',
    'Garlic',
  ];

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() => searchQuery = value.toLowerCase().trim());
    });
  }

  Future<void> _refreshIngredients() async {
    ref.invalidate(ingredientsListProvider);
    ref.invalidate(connectivityProvider);
  }

  void _toggleIngredient(String ingredient) {
    final selectedIngredients = ref.read(ingredientsProvider);
    final notifier = ref.read(ingredientsProvider.notifier);
    final quantitiesNotifier = ref.read(ingredientQuantitiesProvider.notifier);

    if (selectedIngredients.contains(ingredient)) {
      notifier.toggleIngredient(ingredient);
      quantitiesNotifier.remove(ingredient);
      return;
    }

    if (selectedIngredients.length < maxSelectedIngredients) {
      notifier.toggleIngredient(ingredient);
      quantitiesNotifier.ensureQuantity(ingredient);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Constants.format(
            Constants.maxIngredientsSelected,
            [maxSelectedIngredients.toString()],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIngredients = ref.watch(ingredientsProvider);
    final ingredientQuantities = ref.watch(ingredientQuantitiesProvider);
    final ingredientsAsync = ref.watch(ingredientsListProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      body: connectivityAsync.when(
        data: (isConnected) {
          if (!isConnected) {
            return _StateMessage(
              icon: FontAwesomeIcons.wifi,
              title: Constants.noInternetConnection,
              actionLabel: Constants.retry,
              onAction: _refreshIngredients,
            );
          }

          return ingredientsAsync.when(
            data: (allIngredients) => RefreshIndicator(
              onRefresh: _refreshIngredients,
              color: AppColors.primaryContainer,
              child: _PantryContent(
                allIngredients: allIngredients,
                selectedIngredients: selectedIngredients,
                ingredientQuantities: ingredientQuantities,
                searchController: _searchController,
                searchQuery: searchQuery,
                onSearchChanged: _onSearchChanged,
                onToggleIngredient: _toggleIngredient,
                onIncrementIngredient: (ingredient) => ref
                    .read(ingredientQuantitiesProvider.notifier)
                    .increment(ingredient),
                onDecrementIngredient: (ingredient) {
                  final quantity = ref
                      .read(ingredientQuantitiesProvider.notifier)
                      .quantityFor(ingredient);
                  if (quantity <= 1) {
                    _toggleIngredient(ingredient);
                  } else {
                    ref
                        .read(ingredientQuantitiesProvider.notifier)
                        .decrement(ingredient);
                  }
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _StateMessage(
              icon: FontAwesomeIcons.triangleExclamation,
              title: '${Constants.loadingError} $error',
              actionLabel: Constants.retry,
              onAction: _refreshIngredients,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _StateMessage(
          icon: FontAwesomeIcons.triangleExclamation,
          title: '${Constants.networkError} $error',
          actionLabel: Constants.retry,
          onAction: _refreshIngredients,
        ),
      ),
    );
  }
}

class _PantryContent extends StatelessWidget {
  final List<String> allIngredients;
  final List<String> selectedIngredients;
  final Map<String, int> ingredientQuantities;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onToggleIngredient;
  final ValueChanged<String> onIncrementIngredient;
  final ValueChanged<String> onDecrementIngredient;

  const _PantryContent({
    required this.allIngredients,
    required this.selectedIngredients,
    required this.ingredientQuantities,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onToggleIngredient,
    required this.onIncrementIngredient,
    required this.onDecrementIngredient,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = _searchResults();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            sliver: SliverList.list(
              children: [
                const _TopBar(),
                const SizedBox(height: 22),
                Text(
                  'Build your pantry',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 28,
                        height: 34 / 28,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add the ingredients you have on hand to discover '
                  'personalized recipes.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                        height: 19 / 13,
                      ),
                ),
                const SizedBox(height: 20),
                _SearchField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                ),
                const SizedBox(height: 18),
                if (searchQuery.isEmpty)
                  _QuickAddSection(
                    selectedIngredients: selectedIngredients,
                    onToggleIngredient: onToggleIngredient,
                  )
                else
                  _SearchResultsSection(
                    ingredients: suggestions,
                    selectedIngredients: selectedIngredients,
                    onToggleIngredient: onToggleIngredient,
                  ),
                const SizedBox(height: 32),
                _SectionHeader(
                  title: 'My Pantry',
                  trailing: '${selectedIngredients.length} items',
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (selectedIngredients.isEmpty)
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _EmptyPantryCard(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: selectedIngredients.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ingredient = selectedIngredients[index];
                return _PantryItemCard(
                  ingredient: ingredient,
                  quantity: ingredientQuantities[ingredient] ?? 1,
                  onIncrement: () => onIncrementIngredient(ingredient),
                  onDecrement: () => onDecrementIngredient(ingredient),
                );
              },
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
          sliver: SliverToBoxAdapter(
            child: _SmartSuggestionsCard(
              selectedCount: selectedIngredients.length,
            ),
          ),
        ),
      ],
    );
  }

  List<String> _searchResults() {
    if (searchQuery.isEmpty) return const [];
    return allIngredients
        .where((ingredient) => ingredient.toLowerCase().contains(searchQuery))
        .take(12)
        .toList();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.utensils, size: 13),
        const SizedBox(width: 6),
        Text(
          'Savor',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: 17,
          onPressed: () {},
          icon: const Icon(FontAwesomeIcons.magnifyingGlass),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        cursorColor: AppColors.primaryContainer,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Search ingredients (e.g. Garlic, Kale)',
          hintStyle: TextStyle(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.78),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            FontAwesomeIcons.magnifyingGlass,
            color: AppColors.onSurfaceVariant,
            size: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryContainer),
          ),
        ),
      ),
    );
  }
}

class _QuickAddSection extends StatelessWidget {
  final List<String> selectedIngredients;
  final ValueChanged<String> onToggleIngredient;

  const _QuickAddSection({
    required this.selectedIngredients,
    required this.onToggleIngredient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Quick Add'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _IngredientsScreenState._quickAddIngredients.map(
            (ingredient) {
              return _IngredientChip(
                ingredient: ingredient,
                isSelected: selectedIngredients.contains(ingredient),
                onTap: () => onToggleIngredient(ingredient),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class _SearchResultsSection extends StatelessWidget {
  final List<String> ingredients;
  final List<String> selectedIngredients;
  final ValueChanged<String> onToggleIngredient;

  const _SearchResultsSection({
    required this.ingredients,
    required this.selectedIngredients,
    required this.onToggleIngredient,
  });

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const _EmptyInlineMessage(Constants.nothingFound);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Search Results'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: ingredients.map(
            (ingredient) {
              return _IngredientChip(
                ingredient: ingredient,
                isSelected: selectedIngredients.contains(ingredient),
                onTap: () => onToggleIngredient(ingredient),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}

class _IngredientChip extends StatelessWidget {
  final String ingredient;
  final bool isSelected;
  final VoidCallback onTap;

  const _IngredientChip({
    required this.ingredient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = IngredientIcons.forName(ingredient);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              iconData.icon,
              size: 12,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              ingredient,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(
              isSelected ? FontAwesomeIcons.check : FontAwesomeIcons.plus,
              size: 10,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SectionLabel(title),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            trailing,
            style: const TextStyle(
              color: AppColors.primaryContainer,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _PantryItemCard extends StatelessWidget {
  final String ingredient;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _PantryItemCard({
    required this.ingredient,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = IngredientIcons.forName(ingredient);

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                iconData.icon,
                size: 17,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${iconData.category} • Fresh',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _RoundIconButton(
            icon: FontAwesomeIcons.minus,
            onPressed: onDecrement,
          ),
          const SizedBox(width: 10),
          Text(
            quantity.toString(),
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          _RoundIconButton(
            icon: FontAwesomeIcons.plus,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: IconButton(
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerLow,
          foregroundColor: AppColors.onSurfaceVariant,
        ),
        onPressed: onPressed,
        icon: FaIcon(icon, size: 10),
      ),
    );
  }
}

class _SmartSuggestionsCard extends StatelessWidget {
  final int selectedCount;

  const _SmartSuggestionsCard({required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    final hasEnoughIngredients = selectedCount > 0;

    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -16,
            child: Icon(
              FontAwesomeIcons.bowlFood,
              size: 82,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Smart Suggestions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasEnoughIngredients
                    ? 'Based on your pantry, you are close to making '
                        'fresh recipe ideas.'
                    : 'Add a few ingredients to unlock personalized recipes.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                  height: 18 / 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'See Recipes →',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPantryCard extends StatelessWidget {
  const _EmptyPantryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const _EmptyInlineMessage('Add ingredients to build your pantry.'),
    );
  }
}

class _EmptyInlineMessage extends StatelessWidget {
  final String message;

  const _EmptyInlineMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: AppColors.primaryContainer, size: 28),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
