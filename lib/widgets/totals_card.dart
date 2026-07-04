import 'package:flutter/material.dart';

import 'package:bwthw_project/state/meal_store.dart';
import 'package:bwthw_project/theme.dart';


class TotalsCard extends StatelessWidget {
  const TotalsCard({super.key, required this.store});

  final MealStore store;

  //builds the appropriate card widget to show grouped entries
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MEAL TOTALS', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //displays complete macro breakdown of foods in the page
              _ItemInfo(
                label: 'kcal',
                value: store.totalCalories.toStringAsFixed(0),
                color: AppColors.text,
              ),
              _ItemInfo(
                label: 'protein',
                value: '${store.totalProtein.toStringAsFixed(1)}g',
                color: AppColors.protein,
              ),
              _ItemInfo(
                label: 'carbs',
                value: '${store.totalCarbs.toStringAsFixed(1)}g',
                color: AppColors.carbs,
              ),
              _ItemInfo(
                label: 'fat',
                value: '${store.totalFat.toStringAsFixed(1)}g',
                color: AppColors.fat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//displays nutritional data for a single dish, kept private
class _ItemInfo extends StatelessWidget {
  const _ItemInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, //minimizes used space
      children: [
        Text(value, style: displayNumber(size: 26, color: color)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
