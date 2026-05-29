import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ingredio/core/utils/app_routes.dart';
import 'package:ingredio/core/utils/app_theme.dart';
import 'package:ingredio/domain/entities/recipe.dart';
import 'package:ingredio/presentation/providers/favorites_provider.dart';
import 'package:ingredio/presentation/providers/ingredient_quantities_provider.dart';
import 'package:ingredio/presentation/providers/ingredients_provider.dart';
import 'package:ingredio/presentation/providers/recipes_provider.dart';
import 'package:ingredio/presentation/providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final Set<String> _preferences = {'Vegetarian', 'High Protein'};
  final List<_RecipeCollection> _collections = [
    const _RecipeCollection(
      id: 1,
      title: 'Weekly Favorites',
      count: 0,
      icon: FontAwesomeIcons.solidHeart,
      color: AppColors.secondaryContainer,
    ),
    const _RecipeCollection(
      id: 2,
      title: 'Pantry Ready',
      count: 0,
      icon: FontAwesomeIcons.boxOpen,
      color: AppColors.primaryContainer,
    ),
    const _RecipeCollection(
      id: 3,
      title: 'Healthy Picks',
      count: 0,
      icon: FontAwesomeIcons.leaf,
      color: AppColors.primaryContainer,
    ),
    const _RecipeCollection(
      id: 4,
      title: 'To Try Next',
      count: 0,
      icon: FontAwesomeIcons.bookOpen,
      color: AppColors.secondary,
    ),
  ];
  int _nextCollectionId = 5;

  void _showNameSheet(String currentName) {
    final controller = TextEditingController(text: currentName);
    String? errorText;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile name',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      errorText: errorText,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setSheetState(() => errorText = null);
                      }
                    },
                    onSubmitted: (_) async {
                      await _saveNameFromSheet(
                        controller.text,
                        setSheetState,
                        (value) => errorText = value,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveNameFromSheet(
                          controller.text,
                          setSheetState,
                          (value) => errorText = value,
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  Future<void> _saveNameFromSheet(
    String value,
    void Function(void Function()) setSheetState,
    void Function(String?) setError,
  ) async {
    final name = value.trim();
    if (name.isEmpty) {
      setSheetState(() => setError('Name is required'));
      return;
    }

    await ref.read(userProfileProvider.notifier).register(name);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _logout() async {
    await ref.read(userProfileProvider.notifier).logout();
    if (!mounted) return;
    _goToRegister();
  }

  Future<void> _confirmDeleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete all data?'),
          content: const Text(
            'This will remove your profile, pantry items, favorites, cached recipes, and preferences from this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete all data'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(userProfileProvider.notifier).deleteAllData();
    ref.invalidate(ingredientsProvider);
    ref.invalidate(ingredientQuantitiesProvider);
    ref.invalidate(favoritesProvider);
    ref.invalidate(recipesProvider);

    if (!mounted) return;
    _goToRegister();
  }

  void _goToRegister() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.register,
      (_) => false,
    );
  }

  void _togglePreference(String preference) {
    setState(() {
      if (_preferences.contains(preference)) {
        _preferences.remove(preference);
      } else {
        _preferences.add(preference);
      }
    });
  }

  void _showPreferencesSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        const options = [
          'Vegetarian',
          'High Protein',
          'Low Carb',
          'Quick Meals',
          'No Dairy',
          'Budget Friendly',
        ];

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dietary Preferences',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: options.map((option) {
                      final selected = _preferences.contains(option);
                      return FilterChip(
                        selected: selected,
                        label: Text(option),
                        onSelected: (_) {
                          setSheetState(() => _togglePreference(option));
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCollectionSheet({_RecipeCollection? collection}) {
    final isEditing = collection != null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _CollectionSheetContent(
          initialTitle: collection?.title ?? '',
          isEditing: isEditing,
          onDelete: isEditing
              ? () {
                  setState(() {
                    _collections.removeWhere(
                      (item) => item.id == collection.id,
                    );
                  });
                }
              : null,
          onSubmit: (title) {
            setState(() {
              if (isEditing) {
                final index =
                    _collections.indexWhere((item) => item.id == collection.id);
                if (index != -1) {
                  _collections[index] =
                      _collections[index].copyWith(title: title);
                }
              } else {
                _collections.add(
                  _RecipeCollection(
                    id: _nextCollectionId++,
                    title: title,
                    count: 0,
                    icon: FontAwesomeIcons.bookmark,
                    color: AppColors.primaryContainer,
                  ),
                );
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pantryItems = ref.watch(ingredientsProvider);
    final profile = ref.watch(userProfileProvider);
    final quantities = ref.watch(ingredientQuantitiesProvider);
    final favorites = ref.watch(favoritesProvider);
    final recipesAsync = ref.watch(recipesProvider);
    final allRecipes = recipesAsync.maybeWhen(
      data: (recipes) => recipes,
      orElse: () => const <Recipe>[],
    );
    final availableRecipes = _mergeRecipes(favorites, allRecipes);
    final recipesCount = recipesAsync.maybeWhen(
      data: (recipes) => recipes.length,
      orElse: () => 0,
    );
    final storedQuantity = quantities.values.fold<int>(
      0,
      (total, quantity) => total + quantity,
    );
    final totalQuantity =
        storedQuantity > 0 ? storedQuantity : pantryItems.length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
              sliver: SliverList.list(
                children: [
                  const _TopBar(),
                  const SizedBox(height: 14),
                  _ProfileHeader(
                    name: profile.name ?? '',
                    onEdit: () => _showNameSheet(profile.name ?? ''),
                  ),
                  const SizedBox(height: 16),
                  _StatsGrid(
                    pantryItems: pantryItems.length,
                    totalQuantity: totalQuantity,
                    recipesCount: recipesCount,
                    favoritesCount: favorites.length,
                  ),
                  const SizedBox(height: 18),
                  _PreferenceCard(
                    preferences: _preferences,
                    onEdit: _showPreferencesSheet,
                  ),
                  const SizedBox(height: 18),
                  _SectionHeader(
                    title: 'Favorite Recipes',
                    actionLabel: favorites.isEmpty ? null : 'View all',
                  ),
                  const SizedBox(height: 12),
                  if (favorites.isEmpty)
                    const _EmptyCard(
                      icon: FontAwesomeIcons.heart,
                      text: 'Saved recipes will appear here.',
                    )
                  else
                    ...favorites.take(3).map(
                          (recipe) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _FavoriteRecipeCard(recipe: recipe),
                          ),
                        ),
                  const SizedBox(height: 12),
                  _SectionHeader(
                    title: 'My Collections',
                    actionLabel: 'Add',
                    onAction: () => _showCollectionSheet(),
                  ),
                  const SizedBox(height: 12),
                  _CollectionsGrid(
                    collections: _hydratedCollections(
                      favoritesCount: favorites.length,
                    ),
                    onOpen: (collection) => _showCollectionRecipesSheet(
                      collection: collection,
                      favorites: favorites,
                      availableRecipes: availableRecipes,
                    ),
                    onEdit: (collection) =>
                        _showCollectionSheet(collection: collection),
                  ),
                  const SizedBox(height: 20),
                  _AccountActions(
                    onLogout: _logout,
                    onDeleteAllData: _confirmDeleteAllData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_RecipeCollection> _hydratedCollections({
    required int favoritesCount,
  }) {
    return _collections.map((collection) {
      final count = collection.id == 1 && collection.recipeIds.isEmpty
          ? favoritesCount
          : collection.recipeIds.length;
      return collection.copyWith(count: count);
    }).toList();
  }

  List<Recipe> _mergeRecipes(List<Recipe> favorites, List<Recipe> recipes) {
    final merged = <String, Recipe>{};
    for (final recipe in [...favorites, ...recipes]) {
      merged[recipe.id] = recipe;
    }
    return merged.values.toList();
  }

  List<Recipe> _recipesForCollection({
    required _RecipeCollection collection,
    required List<Recipe> favorites,
    required List<Recipe> availableRecipes,
  }) {
    if (collection.id == 1 && collection.recipeIds.isEmpty) {
      return favorites;
    }

    final recipesById = {
      for (final recipe in availableRecipes) recipe.id: recipe
    };
    return collection.recipeIds
        .map((id) => recipesById[id])
        .whereType<Recipe>()
        .toList();
  }

  void _setCollectionRecipeIds(int collectionId, Set<String> recipeIds) {
    setState(() {
      final index = _collections.indexWhere((item) => item.id == collectionId);
      if (index == -1) return;
      _collections[index] = _collections[index].copyWith(recipeIds: recipeIds);
    });
  }

  void _addRecipeToCollection({
    required int collectionId,
    required Recipe recipe,
    required List<Recipe> favorites,
  }) {
    final collection =
        _collections.firstWhere((item) => item.id == collectionId);
    final recipeIds = collection.id == 1 && collection.recipeIds.isEmpty
        ? favorites.map((item) => item.id).toSet()
        : {...collection.recipeIds};
    recipeIds.add(recipe.id);
    _setCollectionRecipeIds(collectionId, recipeIds);
  }

  void _removeRecipeFromCollection({
    required int collectionId,
    required Recipe recipe,
    required List<Recipe> favorites,
  }) {
    final collection =
        _collections.firstWhere((item) => item.id == collectionId);
    final recipeIds = collection.id == 1 && collection.recipeIds.isEmpty
        ? favorites.map((item) => item.id).toSet()
        : {...collection.recipeIds};
    recipeIds.remove(recipe.id);
    _setCollectionRecipeIds(collectionId, recipeIds);
  }

  void _showCollectionRecipesSheet({
    required _RecipeCollection collection,
    required List<Recipe> favorites,
    required List<Recipe> availableRecipes,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentCollection =
                _collections.firstWhere((item) => item.id == collection.id);
            final collectionRecipes = _recipesForCollection(
              collection: currentCollection,
              favorites: favorites,
              availableRecipes: availableRecipes,
            );

            return _CollectionRecipesSheet(
              collection: currentCollection,
              recipes: collectionRecipes,
              onAddRecipe: () {
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showAddRecipeSheet(
                    collection: currentCollection,
                    favorites: favorites,
                    availableRecipes: availableRecipes,
                  );
                });
              },
              onRemoveRecipe: (recipe) {
                _removeRecipeFromCollection(
                  collectionId: currentCollection.id,
                  recipe: recipe,
                  favorites: favorites,
                );
                setSheetState(() {});
              },
            );
          },
        );
      },
    );
  }

  void _showAddRecipeSheet({
    required _RecipeCollection collection,
    required List<Recipe> favorites,
    required List<Recipe> availableRecipes,
  }) {
    final collectionRecipes = _recipesForCollection(
      collection: collection,
      favorites: favorites,
      availableRecipes: availableRecipes,
    );
    final collectionRecipeIds =
        collectionRecipes.map((recipe) => recipe.id).toSet();
    final recipesToAdd = availableRecipes
        .where((recipe) => !collectionRecipeIds.contains(recipe.id))
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _AddRecipeToCollectionSheet(
          collectionTitle: collection.title,
          recipes: recipesToAdd,
          onAdd: (recipe) {
            _addRecipeToCollection(
              collectionId: collection.id,
              recipe: recipe,
              favorites: favorites,
            );
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final updatedCollection =
                  _collections.firstWhere((item) => item.id == collection.id);
              _showCollectionRecipesSheet(
                collection: updatedCollection,
                favorites: favorites,
                availableRecipes: availableRecipes,
              );
            });
          },
        );
      },
    );
  }
}

class _CollectionSheetContent extends StatefulWidget {
  final String initialTitle;
  final bool isEditing;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onDelete;

  const _CollectionSheetContent({
    required this.initialTitle,
    required this.isEditing,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<_CollectionSheetContent> createState() =>
      _CollectionSheetContentState();
}

class _CollectionSheetContentState extends State<_CollectionSheetContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSubmit(title);
    });
  }

  void _delete() {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDelete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Edit Collection' : 'New Collection',
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Collection name',
                hintText: 'e.g. Dinner Ideas',
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (widget.isEditing)
                  TextButton.icon(
                    onPressed: _delete,
                    icon: const FaIcon(FontAwesomeIcons.trash, size: 13),
                    label: const Text('Delete'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.isEditing ? 'Save' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionRecipesSheet extends StatelessWidget {
  final _RecipeCollection collection;
  final List<Recipe> recipes;
  final VoidCallback onAddRecipe;
  final ValueChanged<Recipe> onRemoveRecipe;

  const _CollectionRecipesSheet({
    required this.collection,
    required this.recipes,
    required this.onAddRecipe,
    required this.onRemoveRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.42,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    collection.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddRecipe,
                  icon: const FaIcon(FontAwesomeIcons.plus, size: 12),
                  label: const Text('Add Recipe'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recipes.isEmpty)
              const _EmptyCard(
                icon: FontAwesomeIcons.bookOpen,
                text: 'No recipes in this collection yet.',
              )
            else
              ...recipes.map(
                (recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CollectionRecipeCard(
                    recipe: recipe,
                    onRemove: () => onRemoveRecipe(recipe),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AddRecipeToCollectionSheet extends StatelessWidget {
  final String collectionTitle;
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onAdd;

  const _AddRecipeToCollectionSheet({
    required this.collectionTitle,
    required this.recipes,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.38,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          children: [
            Text(
              'Add to $collectionTitle',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            if (recipes.isEmpty)
              const _EmptyCard(
                icon: FontAwesomeIcons.bookmark,
                text: 'No recipes available to add.',
              )
            else
              ...recipes.map(
                (recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecipePickerTile(
                    recipe: recipe,
                    onAdd: () => onAdd(recipe),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RecipePickerTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onAdd;

  const _RecipePickerTile({
    required this.recipe,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: AppColors.surfaceContainerLow,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: recipe.thumbnail == null || recipe.thumbnail!.isEmpty
            ? const _ImageFallback(width: 52, height: 52)
            : CachedNetworkImage(
                imageUrl: recipe.thumbnail!,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const _ImageFallback(width: 52, height: 52),
                errorWidget: (context, url, error) =>
                    const _ImageFallback(width: 52, height: 52),
              ),
      ),
      title: Text(
        recipe.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text('${recipe.matchCount} pantry matches'),
      trailing: IconButton(
        tooltip: 'Add recipe',
        onPressed: onAdd,
        icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
      ),
      onTap: onAdd,
    );
  }
}

class _CollectionRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onRemove;

  const _CollectionRecipeCard({
    required this.recipe,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(14),
            ),
            child: recipe.thumbnail == null || recipe.thumbnail!.isEmpty
                ? const _ImageFallback(width: 92, height: 96)
                : CachedNetworkImage(
                    imageUrl: recipe.thumbnail!,
                    width: 92,
                    height: 96,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const _ImageFallback(width: 92, height: 96),
                    errorWidget: (context, url, error) =>
                        const _ImageFallback(width: 92, height: 96),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${recipe.matchCount} pantry matches',
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remove from collection',
            onPressed: onRemove,
            icon: const FaIcon(FontAwesomeIcons.xmark, size: 15),
          ),
        ],
      ),
    );
  }
}

class _RecipeCollection {
  final int id;
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final Set<String> recipeIds;

  const _RecipeCollection({
    required this.id,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.recipeIds = const {},
  });

  _RecipeCollection copyWith({
    String? title,
    int? count,
    IconData? icon,
    Color? color,
    Set<String>? recipeIds,
  }) {
    return _RecipeCollection(
      id: id,
      title: title ?? this.title,
      count: count ?? this.count,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      recipeIds: recipeIds ?? this.recipeIds,
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
                color: AppColors.onSurface,
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: 17,
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.settings);
          },
          icon: const FaIcon(FontAwesomeIcons.gear),
        ),
      ],
    );
  }
}

class _AccountActions extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeleteAllData;

  const _AccountActions({
    required this.onLogout,
    required this.onDeleteAllData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: onLogout,
          icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 14),
          label: const Text('Logout'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: AppColors.primaryContainer.withValues(alpha: 0.22),
            ),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onDeleteAllData,
          icon: const FaIcon(FontAwesomeIcons.trash, size: 14),
          label: const Text('Logout and delete all data'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade200),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.name,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Column(
      children: [
        GestureDetector(
          onTap: onEdit,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 3),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.pen,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name.isEmpty ? 'Profil' : name,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Home cook • Pantry optimizer',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int pantryItems;
  final int totalQuantity;
  final int recipesCount;
  final int favoritesCount;

  const _StatsGrid({
    required this.pantryItems,
    required this.totalQuantity,
    required this.recipesCount,
    required this.favoritesCount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.85,
      children: [
        _StatCard(
          icon: FontAwesomeIcons.boxOpen,
          label: 'Pantry Items',
          value: pantryItems.toString(),
          color: AppColors.surfaceContainerLow,
        ),
        _StatCard(
          icon: FontAwesomeIcons.layerGroup,
          label: 'Total Stock',
          value: totalQuantity.toString(),
          color: AppColors.primaryContainer,
          dark: true,
        ),
        _StatCard(
          icon: FontAwesomeIcons.utensils,
          label: 'Recipes Found',
          value: recipesCount.toString(),
          color: AppColors.secondaryContainer,
          dark: true,
        ),
        _StatCard(
          icon: FontAwesomeIcons.solidHeart,
          label: 'Favorites',
          value: favoritesCount.toString(),
          color: AppColors.surfaceContainerLow,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool dark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 16,
            color: dark ? Colors.white : AppColors.primaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: dark ? Colors.white : AppColors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.76)
                        : AppColors.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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

class _PreferenceCard extends StatelessWidget {
  final Set<String> preferences;
  final VoidCallback onEdit;

  const _PreferenceCard({
    required this.preferences,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Dietary Preferences',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onEdit,
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: preferences.isEmpty
                ? [
                    const _PreferencePill(label: 'No preferences set'),
                  ]
                : preferences
                    .map((preference) => _PreferencePill(label: preference))
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _PreferencePill extends StatelessWidget {
  final String label;

  const _PreferencePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryContainer,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _FavoriteRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _FavoriteRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.recipeDetail,
          arguments: RecipeDetailRouteArgs(recipeId: recipe.id),
        );
      },
      child: Container(
        height: 116,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
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
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: recipe.thumbnail == null || recipe.thumbnail!.isEmpty
                  ? const _ImageFallback(width: 110, height: 116)
                  : CachedNetworkImage(
                      imageUrl: recipe.thumbnail!,
                      width: 110,
                      height: 116,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const _ImageFallback(width: 110, height: 116),
                      errorWidget: (context, url, error) =>
                          const _ImageFallback(width: 110, height: 116),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${recipe.matchCount} pantry matches',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: FaIcon(
                FontAwesomeIcons.solidHeart,
                color: AppColors.secondaryContainer,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionsGrid extends StatelessWidget {
  final List<_RecipeCollection> collections;
  final ValueChanged<_RecipeCollection> onOpen;
  final ValueChanged<_RecipeCollection> onEdit;

  const _CollectionsGrid({
    required this.collections,
    required this.onOpen,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.28,
      children: collections
          .map(
            (collection) => _CollectionCard(
              collection: collection,
              onOpen: () => onOpen(collection),
              onEdit: () => onEdit(collection),
            ),
          )
          .toList(),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final _RecipeCollection collection;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

  const _CollectionCard({
    required this.collection,
    required this.onOpen,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: collection.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(collection.icon,
                        color: collection.color, size: 16),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Edit collection',
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  icon: const FaIcon(
                    FontAwesomeIcons.pen,
                    color: AppColors.onSurfaceVariant,
                    size: 11,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              collection.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${collection.count} recipes',
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyCard({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          FaIcon(icon, color: AppColors.primaryContainer, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final double width;
  final double height;

  const _ImageFallback({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
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
