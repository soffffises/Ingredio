import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ingredio/presentation/providers/theme_mode_provider.dart';
import 'package:ingredio/presentation/widgets/theme_mode_selector.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ThemeModeSelector(
            value: themeMode,
            onChanged: (mode) {
              ref.read(themeModeProvider.notifier).setThemeMode(mode);
            },
            title: 'Appearance',
            helperText: 'System follows the device setting automatically.',
          ),
        ],
      ),
    );
  }
}
