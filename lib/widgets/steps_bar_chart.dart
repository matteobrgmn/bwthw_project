
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

    // scegli ordine di grandezza "umano"
    final magnitude = 1000.0;

    // arrotonda base a step pulito
    final normalizedBase = (base / magnitude).ceil() * magnitude;

    // evita interval = 0 o troppo piccolo
    return normalizedBase < magnitude ? magnitude : normalizedBase;
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = _maxY();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly steps",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxValue + 1000,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int i = value.toInt();
                        if (i < 0 || i >= data.length) return const Text("");
                        return Text(
                          data[i].label,
                          style: const TextStyle(fontSize: 11),
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
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),

                barGroups: List.generate(data.length, (i) {
                  final value = data[i].value;

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
                              ? [Colors.orange, Colors.deepOrange]
                              : [Colors.deepPurple, Colors.purpleAccent],
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