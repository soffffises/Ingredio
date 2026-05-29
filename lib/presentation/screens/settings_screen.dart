import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ingredio/core/utils/app_theme.dart';
import 'package:ingredio/presentation/providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: isDarkMode,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setDarkMode(value);
              },
              title: const Text('Dark mode'),
              subtitle: const Text('Use a darker color palette in the app.'),
            ),
          ),
        ],
      ),
    );
  }
}
