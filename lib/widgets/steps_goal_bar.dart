import 'package:flutter/material.dart';
import '../theme.dart';

class StepsGoalBar extends StatelessWidget {
  final int currentSteps;
  final int goalSteps;

  const StepsGoalBar({
    super.key,
    required this.currentSteps,
    this.goalSteps = 10000,
  });

  @override
  Widget build(BuildContext context) {
    double progress = currentSteps / goalSteps;

    if (progress > 1) {
      progress = 1;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flag,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Daily Steps Goal",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Text(
                "$currentSteps / $goalSteps",
                style: displayNumber(
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 18,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              color: AppColors.accent,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            currentSteps >= goalSteps
                ? "Goal completed"
                : "${goalSteps - currentSteps} steps left",
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}