import 'package:flutter/material.dart';

import 'package:bwthw_project/nutrition/models/meal_entry.dart';

//handy display of macros in chip format
class MacrosChips extends StatelessWidget {
  const MacrosChips({super.key, required this.entry});

  final MealEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = entry.hasNutritionData;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.4);

    String kcal = hasData ? '${entry.scaledCalories.toStringAsFixed(0)} kcal' : '— kcal';
    String p = hasData ? 'P ${entry.scaledProtein.toStringAsFixed(1)}g' : 'P —';
    String c = hasData ? 'C ${entry.scaledCarbs.toStringAsFixed(1)}g' : 'C —';
    String f = hasData ? 'F ${entry.scaledFat.toStringAsFixed(1)}g' : 'F —';

    final labels = [kcal, p, c, f];

    //wrap and container for appropriate spacing and displaying
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: labels.map((label) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasData
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : muted,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: hasData ? theme.colorScheme.onSurface : muted,
            ),
          ),
        );
      }).toList(),
    );
  }
}
