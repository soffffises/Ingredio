import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:ingredio/core/utils/app_theme.dart';
import 'package:ingredio/presentation/providers/connectivity_provider.dart';
import 'package:ingredio/presentation/providers/recipes_provider.dart';
import 'package:ingredio/presentation/widgets/recipe_tile.dart';

class RecipesBrowserScreen extends ConsumerStatefulWidget {
  const RecipesBrowserScreen({super.key});

  @override
  ConsumerState<RecipesBrowserScreen> createState() =>
      _RecipesBrowserScreenState();
}

class _RecipesBrowserScreenState extends ConsumerState<RecipesBrowserScreen> {
  static const int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter > 600) return;
    setState(() {
      _visibleCount += _pageSize;
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(recipesProvider);
    ref.invalidate(connectivityProvider);
    setState(() {
      _visibleCount = _pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Recipes'),
      ),
      body: connectivityAsync.when(
        data: (isConnected) {
          if (!isConnected) {
            return _StateMessage(
              icon: FontAwesomeIcons.wifi,
              title: 'No internet connection',
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          }

          return recipesAsync.when(
            data: (recipes) {
              final visibleCount = recipes.length < _visibleCount
                  ? recipes.length
                  : _visibleCount;
              final hasMore = visibleCount < recipes.length;

              if (recipes.isEmpty) {
                return const _StateMessage(
                  icon: FontAwesomeIcons.bowlFood,
                  title: 'No recipes found.',
                  actionLabel: '',
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primaryContainer,
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: visibleCount + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= visibleCount) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return RecipeTile(recipe: recipes[index]);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _StateMessage(
              icon: FontAwesomeIcons.triangleExclamation,
              title: 'Error loading recipes: $error',
              actionLabel: 'Retry',
              onAction: _refresh,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _StateMessage(
          icon: FontAwesomeIcons.triangleExclamation,
          title: 'Network error: $error',
          actionLabel: 'Retry',
          onAction: _refresh,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.actionLabel,
    this.onAction,
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
            if (onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
