import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ingredio/core/utils/app_theme.dart';
import 'package:ingredio/core/utils/constants.dart';
import 'package:ingredio/domain/entities/recipe.dart';
import 'package:ingredio/presentation/providers/connectivity_provider.dart';
import 'package:ingredio/presentation/providers/favorites_provider.dart';
import 'package:ingredio/presentation/providers/hive_database_provider.dart';
import 'package:ingredio/presentation/providers/recipe_detail_provider.dart';
import 'package:ingredio/presentation/widgets/status_state_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  Future<void> _refreshRecipeDetails(WidgetRef ref) async {
    final hiveDatabase = ref.read(hiveDatabaseProvider);
    await hiveDatabase.removeCachedRecipe(recipeId);
    ref.invalidate(recipeDetailProvider(recipeId));
    ref.invalidate(connectivityProvider);
  }

  Future<void> _shareRecipe(BuildContext context, WidgetRef ref) async {
    final recipeDetailAsync = ref.read(recipeDetailProvider(recipeId));
    recipeDetailAsync.when(
      data: (recipe) {
        final shareText = '''
${recipe.name}

${Constants.ingredientsWithMeasures}
${_buildShareIngredients(recipe)}

${Constants.instruction}
${recipe.instructions ?? Constants.noInstruction}

${Constants.category}: ${recipe.category ?? Constants.noCategory}

${recipe.youtubeLink != null ? "${Constants.videoRecipe}: ${recipe.youtubeLink}" : ""}
''';
        Share.share(shareText, subject: recipe.name);
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Constants.recipeLoading)),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${Constants.loadingError} $error')),
        );
      },
    );
  }

  String _buildShareIngredients(Recipe recipe) {
    if (recipe.ingredients.isEmpty) return Constants.noIngredients;
    return recipe.ingredients.asMap().entries.map((entry) {
      final index = entry.key;
      final ingredient = entry.value;
      final measure = recipe.measures != null && recipe.measures!.length > index
          ? recipe.measures![index]
          : '';
      return '$ingredient: $measure';
    }).join('\n');
  }

  Future<void> _launchYouTubeLink(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Constants.invalidUrl)),
      );
      return;
    }

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw '${Constants.couldNotLaunch} $url';
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Constants.error} $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeDetailAsync = ref.watch(recipeDetailProvider(recipeId));
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      body: connectivityAsync.when(
        data: (isConnected) {
          if (!isConnected) {
            return StatusStateView(
              icon: FontAwesomeIcons.wifi,
              title: Constants.noInternetConnection,
              message: 'Open a cached recipe or reconnect to refresh.',
              actionLabel: Constants.retry,
              onAction: () => _refreshRecipeDetails(ref),
            );
          }

          return recipeDetailAsync.when(
            data: (recipe) => _RecipeDetailContent(
              recipe: recipe,
              onRefresh: () => _refreshRecipeDetails(ref),
              onShare: () => _shareRecipe(context, ref),
              onOpenVideo:
                  recipe.youtubeLink == null || recipe.youtubeLink!.isEmpty
                      ? null
                      : () => _launchYouTubeLink(context, recipe.youtubeLink!),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => StatusStateView(
              icon: FontAwesomeIcons.triangleExclamation,
              title: '${Constants.error} $error',
              actionLabel: Constants.retry,
              onAction: () => _refreshRecipeDetails(ref),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => StatusStateView(
          icon: FontAwesomeIcons.triangleExclamation,
          title: '${Constants.networkError} $error',
          message: 'Reconnect and try again.',
          actionLabel: Constants.retry,
          onAction: () => _refreshRecipeDetails(ref),
        ),
      ),
    );
  }
}

class _RecipeDetailContent extends ConsumerWidget {
  final Recipe recipe;
  final Future<void> Function() onRefresh;
  final VoidCallback onShare;
  final VoidCallback? onOpenVideo;

  const _RecipeDetailContent({
    required this.recipe,
    required this.onRefresh,
    required this.onShare,
    required this.onOpenVideo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = _instructionSteps(recipe.instructions);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh,
          color: AppColors.primaryContainer,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _HeroSection(
                  recipe: recipe,
                  onShare: onShare,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 144),
                sliver: SliverList.list(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -14),
                      child: _TitleCard(recipe: recipe),
                    ),
                    _IngredientsSection(recipe: recipe),
                    const SizedBox(height: 22),
                    _StepsSection(steps: steps),
                    if (onOpenVideo != null) ...[
                      const SizedBox(height: 18),
                      _VideoButton(onPressed: onOpenVideo!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
          child: _StartCookingButton(onPressed: onOpenVideo ?? () {}),
        ),
      ],
    );
  }
}

class _HeroSection extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback onShare;

  const _HeroSection({
    required this.recipe,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref
        .watch(favoritesProvider)
        .any((favorite) => favorite.id == recipe.id);

    return SizedBox(
      height: 286,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _RecipeImage(imageUrl: recipe.thumbnail),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CircleActionButton(
                    icon: FontAwesomeIcons.arrowLeft,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _CircleActionButton(
                    icon: FontAwesomeIcons.shareNodes,
                    onPressed: onShare,
                  ),
                  const SizedBox(width: 10),
                  _CircleActionButton(
                    icon: isFavorite
                        ? FontAwesomeIcons.solidHeart
                        : FontAwesomeIcons.heart,
                    active: isFavorite,
                    onPressed: () async {
                      if (isFavorite) {
                        await ref
                            .read(favoritesProvider.notifier)
                            .removeFavorite(recipe.id);
                      } else {
                        await ref
                            .read(favoritesProvider.notifier)
                            .addFavorite(recipe);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  final String? imageUrl;

  const _RecipeImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _ImageFallback();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => const _ImageFallback(),
      errorWidget: (context, url, error) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainer,
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.bowlFood,
          color: AppColors.onSurfaceVariant,
          size: 36,
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;

  const _CircleActionButton({
    required this.icon,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.94),
          foregroundColor:
              active ? AppColors.secondaryContainer : AppColors.onSurface,
        ),
        onPressed: onPressed,
        icon: FaIcon(icon, size: 15),
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  final Recipe recipe;

  const _TitleCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.name,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 22,
              height: 28 / 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A richly matched recipe based on your pantry ingredients.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  height: 17 / 12,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetaTile(
                icon: FontAwesomeIcons.clock,
                label: 'Prep time',
                value: '${_estimatedMinutes(recipe)} min',
              ),
              _MetaTile(
                icon: FontAwesomeIcons.utensils,
                label: 'Category',
                value: recipe.category ?? Constants.noCategory,
              ),
              _MetaTile(
                icon: FontAwesomeIcons.fire,
                label: 'Difficulty',
                value: _difficultyLabel(recipe),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FaIcon(icon, size: 15, color: AppColors.secondary),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  final Recipe recipe;

  const _IngredientsSection({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final ingredients = recipe.ingredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Ingredients Needed',
          trailing: '${ingredients.length} items',
        ),
        const SizedBox(height: 10),
        if (ingredients.isEmpty)
          const _InlineCard(child: Text(Constants.noIngredients))
        else
          ...ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            final measure = recipe.measures != null &&
                    recipe.measures!.length > index &&
                    recipe.measures![index].trim().isNotEmpty
                ? recipe.measures![index]
                : 'as needed';
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _IngredientRow(
                ingredient: ingredient,
                measure: measure,
                isAvailable: index < recipe.matchCount,
              ),
            );
          }),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String ingredient;
  final String measure;
  final bool isAvailable;

  const _IngredientRow({
    required this.ingredient,
    required this.measure,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                isAvailable ? FontAwesomeIcons.check : FontAwesomeIcons.plus,
                size: 10,
                color: isAvailable ? Colors.white : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredient,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              measure,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  final List<String> steps;

  const _StepsSection({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Step-by-Step'),
        const SizedBox(height: 10),
        if (steps.isEmpty)
          const _InlineCard(child: Text(Constants.noInstruction))
        else
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StepCard(
                number: entry.key + 1,
                text: entry.value,
              ),
            );
          }),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String text;

  const _StepCard({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 20 / 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionTitle({
    required this.title,
    this.trailing,
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
        if (trailing != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InlineCard extends StatelessWidget {
  final Widget child;

  const _InlineCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _VideoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _VideoButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const FaIcon(FontAwesomeIcons.circlePlay, size: 15),
        label: const Text(Constants.videoRecipe),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outlineVariant),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _StartCookingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartCookingButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const FaIcon(FontAwesomeIcons.solidCirclePlay, size: 15),
        label: const Text('Start Cooking'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}


List<String> _instructionSteps(String? instructions) {
  final value = instructions?.trim();
  if (value == null || value.isEmpty) return const [];

  final normalized = value.replaceAll('\r', '\n');
  final byLines = normalized
      .split(RegExp(r'\n+'))
      .map((step) => step.trim())
      .where((step) => step.isNotEmpty)
      .toList();
  if (byLines.length > 1) return byLines.take(8).toList();

  return normalized
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((step) => step.trim())
      .where((step) => step.length > 8)
      .take(8)
      .toList();
}

int _estimatedMinutes(Recipe recipe) {
  final base = 15 + (recipe.name.length % 4) * 5;
  return base.clamp(15, 45);
}

String _difficultyLabel(Recipe recipe) {
  if (recipe.ingredients.length > 10) return 'Medium';
  if (recipe.ingredients.length > 6) return 'Easy';
  return 'Simple';
}
