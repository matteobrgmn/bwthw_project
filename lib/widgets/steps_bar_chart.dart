
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:bwthw_project/theme.dart';

class StepData {
  final String label;
  final int value;

  StepData(this.label, this.value);
}

class StepsBarChart extends StatelessWidget {
  final List<StepData> data;

  const StepsBarChart({
    super.key,
    required this.data,
  });

  double _maxY() {
    if (data.isEmpty) return 0;
    return data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
  }

  double _safeInterval(double maxValue) {
    if (maxValue <= 0 || maxValue.isNaN || maxValue.isInfinite) {
      return 1000;
    }

    final base = maxValue / 5;

    final magnitude = 1000.0;

    final normalizedBase = (base / magnitude).ceil() * magnitude;

    return normalizedBase < magnitude ? magnitude : normalizedBase;
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = _maxY();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(20),
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY STEPS',
            style: Theme.of(context).textTheme.titleSmall,
          ),

          const SizedBox(height: 16),

          Expanded(
            child: BarChart(
              BarChartData(
                maxY: ((maxValue / 1000).ceil() + 1) * 1000,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.outline,
                    strokeWidth: 1,
                    dashArray: [4, 6],
                  ),
                ),
                borderData: FlBorderData(show: false),
                // To round the data
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toInt().toString(),
                        const TextStyle(),
                      );
                    },
                  ),
                ),
    
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int i = value.toInt();
                        if (i < 0 || i >= data.length) return const Text("");
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[i].label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: _safeInterval(maxValue),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barGroups: List.generate(data.length, (i) {
                  final value = data[i].value.round();
                  
                  final isMax = value ==
                      data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: value.toDouble(),
                        width: 16,
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: isMax
                              ? [AppColors.accent, const Color(0xFFE9FF70)]
                              : [
                                  AppColors.accent.withValues(alpha: 0.25),
                                  AppColors.accent.withValues(alpha: 0.55),
                                ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
