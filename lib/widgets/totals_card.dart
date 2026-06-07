import 'package:flutter/material.dart';

import 'package:bwthw_project/state/meal_store.dart';


class TotalsCard extends StatelessWidget {
  const TotalsCard({super.key, required this.store});

  final MealStore store;

  //builds the appropriate card widget to show grouped entries
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //displays complete macro breakdown of foods in the page
            _ItemInfo(
              label: 'Calories',
              value: '${store.totalCalories.toStringAsFixed(0)} kcal',
            ),
            _ItemInfo(
              label: 'Protein',
              value: '${store.totalProtein.toStringAsFixed(1)} g',
            ),
            _ItemInfo(
              label: 'Carbs',
              value: '${store.totalCarbs.toStringAsFixed(1)} g',
            ),
            _ItemInfo(
              label: 'Fat',
              value: '${store.totalFat.toStringAsFixed(1)} g',

            ),
          ],
        ),
      ),
    );
  }
}

//displays nutritional data for a single dish, kept private
class _ItemInfo extends StatelessWidget {
  const _ItemInfo({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, //minimizes used space
      children: [
        Text(
          value,
          style: TextStyle( 
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            )
          ),
      ],
    );
  }
}
