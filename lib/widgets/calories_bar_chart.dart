import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CalorieData {
  final String label;
  final double value;
  CalorieData(this.label, this.value);
}

//used for displaying calorie consumption trend in DataPage
class CaloriesBarChart extends StatelessWidget {
  final List<CalorieData> data;

  const CaloriesBarChart({super.key, required this.data});

  double _maxY() {
    if (data.isEmpty) return 0;
    return data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  double _safeInterval(double maxValue) {
    if (maxValue <= 0 || maxValue.isNaN || maxValue.isInfinite) return 500;
    final base = maxValue / 4;
    const magnitude = 500.0;
    final normalized = (base / magnitude).ceil() * magnitude;
    return normalized < magnitude ? magnitude : normalized;
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calorie settimanali',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxValue > 0 ? maxValue + 500 : 2500,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[i].label,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _safeInterval(maxValue),
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
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
                  final isMax = value == maxValue && maxValue > 0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 16,
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: isMax
                              ? [Colors.orange, Colors.deepOrange]
                              : [Colors.orangeAccent, Colors.orange],
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
