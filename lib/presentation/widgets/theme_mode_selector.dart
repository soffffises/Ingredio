import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:ingredio/core/utils/app_theme.dart';

class ThemeModeSelector extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;
  final String title;
  final String helperText;

  const ThemeModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.title = 'Appearance',
    this.helperText = 'System follows the device setting automatically.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.circleHalfStroke,
                size: 14,
                color: AppColors.primaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text('System'),
                icon: FaIcon(FontAwesomeIcons.circleHalfStroke, size: 12),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: FaIcon(FontAwesomeIcons.solidSun, size: 12),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: FaIcon(FontAwesomeIcons.moon, size: 12),
              ),
            ],
            selected: {value},
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              selectedBackgroundColor: AppColors.primaryContainer,
              selectedForegroundColor: Colors.white,
              foregroundColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              side: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.9),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                onChanged(selection.first);
              }
            },
          ),
          const SizedBox(height: 10),
          Text(
            helperText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
