import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ingredio/core/utils/app_theme.dart';
import 'package:ingredio/core/utils/constants.dart';
import 'package:ingredio/presentation/providers/favorites_provider.dart';
import 'package:ingredio/presentation/widgets/recipe_tile.dart';
import 'package:ingredio/presentation/providers/connectivity_provider.dart';
import 'package:ingredio/presentation/widgets/status_state_view.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  Future<void> _refreshFavorites(WidgetRef ref) async {
    ref.invalidate(favoritesProvider);
    ref.invalidate(connectivityProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteRecipes = ref.watch(favoritesProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Constants.favorites)),
      body: connectivityAsync.when(
        data: (isConnected) => RefreshIndicator(
          onRefresh: () => _refreshFavorites(ref),
          child: favoriteRecipes.isEmpty
              ? const _EmptyFavoritesState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: favoriteRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = favoriteRecipes[index];
                        return RecipeTile(
                            recipe: recipe, isFavoriteScreen: true);
                      },
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => StatusStateView(
          icon: FontAwesomeIcons.triangleExclamation,
          title: '${Constants.networkError} $error',
          message: 'Check your connection and try again.',
          actionLabel: Constants.retry,
          onAction: () => _refreshFavorites(ref),
        ),
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: AppColors.secondaryContainer,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Constants.favoritesDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
