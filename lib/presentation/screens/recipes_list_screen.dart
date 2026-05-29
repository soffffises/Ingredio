import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ingredio/core/utils/app_routes.dart';
import 'package:ingredio/core/utils/app_theme.dart';
import 'package:ingredio/core/utils/constants.dart';
import 'package:ingredio/domain/entities/recipe.dart';
import 'package:ingredio/presentation/providers/connectivity_provider.dart';
import 'package:ingredio/presentation/providers/favorites_provider.dart';
import 'package:ingredio/presentation/providers/ingredients_provider.dart';
import 'package:ingredio/presentation/providers/recipes_provider.dart';
import 'package:ingredio/presentation/providers/user_profile_provider.dart';
import 'package:ingredio/presentation/widgets/status_state_view.dart';

class RecipesListScreen extends ConsumerStatefulWidget {
  const RecipesListScreen({super.key});

  @override
  ConsumerState<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends ConsumerState<RecipesListScreen> {
  static const List<String> _filters = [
    'All',
    'Best Match',
    'Quick',
    'Easy',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedFilter = _filters.first;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshRecipes() async {
    ref.invalidate(recipesProvider);
    ref.invalidate(connectivityProvider);
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final ingredients = ref.watch(ingredientsProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      body: connectivityAsync.when(
        data: (isConnected) {
          if (!isConnected) {
            return StatusStateView(
              icon: FontAwesomeIcons.wifi,
              title: Constants.noInternetConnection,
              message: 'Connect to the internet to load recipe suggestions.',
              actionLabel: Constants.retry,
              onAction: _refreshRecipes,
            );
          }

          if (ingredients.isEmpty) {
            return const _EmptyRecipesState();
          }

          return recipesAsync.when(
            data: (recipes) {
              final filteredRecipes = _filteredRecipes(recipes);
              return RefreshIndicator(
                onRefresh: _refreshRecipes,
                color: AppColors.primaryContainer,
                child: _DiscoverContent(
                  recipes: filteredRecipes,
                  userName: profile.name,
                  allRecipesCount: recipes.length,
                  selectedIngredientsCount: ingredients.length,
                  queryController: _searchController,
                  query: _query,
                  selectedFilter: _selectedFilter,
                  filters: _filters,
                  onViewAll: () => Navigator.of(context).pushNamed(
                    AppRoutes.recipes,
                  ),
                  onMore: () => Navigator.of(context).pushNamed(
                    AppRoutes.recipes,
                  ),
                  onQueryChanged: (value) {
                    setState(() => _query = value.toLowerCase().trim());
                  },
                  onFilterSelected: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => StatusStateView(
              icon: FontAwesomeIcons.triangleExclamation,
              title: '${Constants.error} $error',
              actionLabel: Constants.retry,
              onAction: _refreshRecipes,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => StatusStateView(
          icon: FontAwesomeIcons.triangleExclamation,
          title: '${Constants.networkError} $error',
          message: 'Check your connection and try again.',
          actionLabel: Constants.retry,
          onAction: _refreshRecipes,
        ),
      ),
    );
  }

  List<Recipe> _filteredRecipes(List<Recipe> recipes) {
    Iterable<Recipe> filtered = recipes;

    if (_query.isNotEmpty) {
      filtered = filtered.where((recipe) {
        final nameMatch = recipe.name.toLowerCase().contains(_query);
        final ingredientMatch = recipe.matchedIngredients
            .any((ingredient) => ingredient.toLowerCase().contains(_query));
        return nameMatch || ingredientMatch;
      });
    }

    final list = filtered.toList()
      ..sort((a, b) => b.matchCount.compareTo(a.matchCount));

    switch (_selectedFilter) {
      case 'Best Match':
        return list.where((recipe) => recipe.matchCount > 1).toList();
      case 'Quick':
        return list.take(math.min(8, list.length)).toList();
      case 'Easy':
        return list.where((recipe) => recipe.matchCount <= 2).toList();
      default:
        return list;
    }
  }
}

class _DiscoverContent extends StatelessWidget {
  final List<Recipe> recipes;
  final String? userName;
  final int allRecipesCount;
  final int selectedIngredientsCount;
  final TextEditingController queryController;
  final String query;
  final String selectedFilter;
  final List<String> filters;
  final VoidCallback onViewAll;
  final VoidCallback onMore;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onFilterSelected;

  const _DiscoverContent({
    required this.recipes,
    required this.userName,
    required this.allRecipesCount,
    required this.selectedIngredientsCount,
    required this.queryController,
    required this.query,
    required this.selectedFilter,
    required this.filters,
    required this.onViewAll,
    required this.onMore,
    required this.onQueryChanged,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final featuredRecipe = recipes.isNotEmpty ? recipes.first : null;
    final recommended = recipes.skip(1).take(6).toList();
    final trendingStart = featuredRecipe == null ? 0 : 1 + recommended.length;
    final trending = recipes.skip(trendingStart).take(8).toList();
    final trimmedName = userName?.trim();
    final greeting = trimmedName == null || trimmedName.isEmpty
        ? 'Ready to cook?'
        : 'Ready to cook, $trimmedName?';

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
                const SizedBox(height: 18),
                Text(
                  greeting,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 21,
                    height: 26 / 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'We found ${recipes.length} recipes you can make with items '
                  'in your pantry.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 17 / 12,
                      ),
                ),
                const SizedBox(height: 14),
                _SearchField(
                  controller: queryController,
                  onChanged: onQueryChanged,
                ),
                const SizedBox(height: 12),
                _FilterChips(
                  filters: filters,
                  selectedFilter: selectedFilter,
                  onFilterSelected: onFilterSelected,
                ),
                const SizedBox(height: 14),
                if (featuredRecipe == null)
                  _NoRecipesForFilter(query: query)
                else ...[
                  _FeaturedRecipeCard(
                    recipe: featuredRecipe,
                    selectedIngredientsCount: selectedIngredientsCount,
                  ),
                  const SizedBox(height: 14),
                  _StatsRow(
                    recipesCount: allRecipesCount,
                    selectedIngredientsCount: selectedIngredientsCount,
                  ),
                  const SizedBox(height: 18),
                  _SectionHeader(
                    title: 'Recommended for you',
                    actionLabel: 'View all',
                    onAction: onViewAll,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (recommended.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 182,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                scrollDirection: Axis.horizontal,
                itemCount: recommended.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _RecommendedRecipeCard(recipe: recommended[index]);
                },
              ),
            ),
          ),
        if (trending.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            sliver: SliverList.list(
              children: [
                _SectionHeader(
                  title: 'Trending now',
                  actionLabel: 'More',
                  onAction: onMore,
                ),
              ],
            ),
          ),
        if (trending.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
            sliver: SliverList.separated(
              itemCount: trending.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _TrendingRecipeTile(recipe: trending[index]);
              },
            ),
          )
        else
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 112),
          ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const FaIcon(FontAwesomeIcons.utensils, size: 13),
        const SizedBox(width: 6),
        Text(
          'Savor',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: 17,
          onPressed: () {},
          icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
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
      height: 42,
      child: TextField(
        controller: controller,
        cursorColor: AppColors.primaryContainer,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Search recipes or ingredients',
          hintStyle: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.78),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            FontAwesomeIcons.magnifyingGlass,
            size: 13,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          fillColor: Theme.of(context).colorScheme.surface,
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

class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const _FilterChips({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;
          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onFilterSelected(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.primaryContainer : AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.outlineVariant,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int selectedIngredientsCount;

  const _FeaturedRecipeCard({
    required this.recipe,
    required this.selectedIngredientsCount,
  });

  @override
  Widget build(BuildContext context) {
    return _RecipeTapTarget(
      recipe: recipe,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _RecipeImage(
                  imageUrl: recipe.thumbnail,
                  height: 154,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _StatusPill(
                    icon: FontAwesomeIcons.circleCheck,
                    label: _availabilityLabel(recipe, selectedIngredientsCount),
                    dark: true,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _FavoriteButton(recipe: recipe),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.clock,
                        size: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${_estimatedMinutes(recipe)} min',
                        style: _metaStyle,
                      ),
                      const SizedBox(width: 12),
                      const FaIcon(
                        FontAwesomeIcons.fire,
                        size: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(_difficultyLabel(recipe), style: _metaStyle),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int recipesCount;
  final int selectedIngredientsCount;

  const _StatsRow({
    required this.recipesCount,
    required this.selectedIngredientsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            color: AppColors.secondaryContainer,
            icon: FontAwesomeIcons.clipboardList,
            label: 'Recipes Matched',
            value: recipesCount.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            color: AppColors.primaryContainer,
            icon: FontAwesomeIcons.boxOpen,
            label: 'Pantry Items',
            value: selectedIngredientsCount.toString(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: FaIcon(icon, size: 14, color: Colors.white),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (onAction != null)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  FaIcon(
                    FontAwesomeIcons.arrowRight,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 10,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RecommendedRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _RecommendedRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return _RecipeTapTarget(
      recipe: recipe,
      child: SizedBox(
        width: 138,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecipeImage(
                imageUrl: recipe.thumbnail,
                height: 92,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 12,
                        height: 15 / 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_estimatedMinutes(recipe)} min • ${recipe.matchCount} matches',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _metaStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingRecipeTile extends StatelessWidget {
  final Recipe recipe;

  const _TrendingRecipeTile({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return _RecipeTapTarget(
      recipe: recipe,
      child: Container(
        height: 82,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            _RecipeImage(
              imageUrl: recipe.thumbnail,
              width: 66,
              height: 66,
              borderRadius: BorderRadius.circular(9),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_estimatedMinutes(recipe)} min • ${_difficultyLabel(recipe)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _metaStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _FavoriteButton(recipe: recipe, compact: true),
          ],
        ),
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const _RecipeImage({
    required this.imageUrl,
    this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: imageUrl == null || imageUrl!.isEmpty
          ? _ImageFallback(width: width, height: height)
          : CachedNetworkImage(
              imageUrl: imageUrl!,
              width: width ?? double.infinity,
              height: height,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  _ImageFallback(width: width, height: height),
              errorWidget: (context, url, error) =>
                  _ImageFallback(width: width, height: height),
            ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final double? width;
  final double height;

  const _ImageFallback({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      color: AppColors.surfaceContainer,
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.bowlFood,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  final Recipe recipe;
  final bool compact;

  const _FavoriteButton({
    required this.recipe,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref
        .watch(favoritesProvider)
        .any((favorite) => favorite.id == recipe.id);

    return SizedBox(
      width: compact ? 34 : 38,
      height: compact ? 34 : 38,
      child: IconButton(
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.88),
          foregroundColor:
              isFavorite ? AppColors.secondaryContainer : AppColors.primary,
        ),
        onPressed: () async {
          if (isFavorite) {
            await ref
                .read(favoritesProvider.notifier)
                .removeFavorite(recipe.id);
          } else {
            await ref.read(favoritesProvider.notifier).addFavorite(recipe);
          }
        },
        icon: FaIcon(
          isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
          size: compact ? 14 : 15,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dark;

  const _StatusPill({
    required this.icon,
    required this.label,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: dark
            ? AppColors.primaryContainer.withValues(alpha: 0.94)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 9, color: dark ? Colors.white : AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: dark ? Colors.white : AppColors.onSurface,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeTapTarget extends StatelessWidget {
  final Recipe recipe;
  final Widget child;

  const _RecipeTapTarget({
    required this.recipe,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.recipeDetail,
          arguments: RecipeDetailRouteArgs(recipeId: recipe.id),
        );
      },
      child: child,
    );
  }
}

class _NoRecipesForFilter extends StatelessWidget {
  final String query;

  const _NoRecipesForFilter({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        query.isEmpty
            ? 'No recipes match this filter.'
            : 'No recipes found for "$query".',
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyRecipesState extends StatelessWidget {
  const _EmptyRecipesState();

  @override
  Widget build(BuildContext context) {
    return const StatusStateView(
      icon: FontAwesomeIcons.boxOpen,
      title: Constants.selectAtLeastOneIngredient,
    );
  }
}

String _availabilityLabel(Recipe recipe, int selectedIngredientsCount) {
  if (selectedIngredientsCount == 0) return 'Add pantry items';
  if (recipe.matchCount >= selectedIngredientsCount) {
    return 'All ingredients available';
  }
  final missing = math.max(selectedIngredientsCount - recipe.matchCount, 1);
  return '$missing missing ingredient${missing == 1 ? '' : 's'}';
}

int _estimatedMinutes(Recipe recipe) {
  final base = 15 + (recipe.name.length % 4) * 5;
  return math.min(base + math.max(0, 4 - recipe.matchCount) * 5, 45);
}

String _difficultyLabel(Recipe recipe) {
  if (recipe.matchCount >= 4) return 'Easy';
  if (recipe.matchCount >= 2) return 'Medium';
  return 'Simple';
}

const TextStyle _metaStyle = TextStyle(
  color: AppColors.onSurfaceVariant,
  fontSize: 11,
  fontWeight: FontWeight.w700,
);
