import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:bwthw_project/impact/impact.dart';
import 'package:bwthw_project/nutrition/models/meal_entry.dart';
import 'package:bwthw_project/state/meal_store.dart';
import 'package:bwthw_project/theme.dart';
import 'package:bwthw_project/widgets/calories_bar_chart.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key, required this.username});

  final String username;

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  bool _initialized = false;
  String? _initError;

  List<CalorieData> _chartData = [];
  double _totalConsumed = 0;
  double _totalBurned = 0;

  final _impact = Impact();

  //constant for calculating the amount of (approximated) kilograms lost/gained based upon the calorie deficit/surplus
  static const double _kcalPerKg = 7700;

  @override
  void initState() {
    super.initState();
    _init();

    Future.microtask(() {
      context.read<DataProvider>().start();
    });
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consumed = _readCaloriesFromPrefs(prefs);
      final burned = <String, double>{};

      double totalConsumed = 0;
      double totalBurned = 0;
      final chartData = <CalorieData>[];

      const dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      final now = DateTime.now();
      for (int i = 7; i >= 1; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = _fmtDate(date);   
        final label = dayLabels[date.weekday - 1];
        final dayConsumed = consumed[dateStr] ?? 0.0;
        totalConsumed += dayConsumed;
        totalBurned += burned[dateStr] ?? 0.0;
        chartData.add(CalorieData(label, dayConsumed));
      }
      if (mounted) {
        setState(() {
          _chartData = chartData;
          _totalConsumed = totalConsumed;
          _totalBurned = totalBurned;
          _initialized = true;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _initError = e.toString());
    }
  }

  //read calories consumed during week from sharedPreferences
  Map<String, double> _readCaloriesFromPrefs(SharedPreferences prefs) {
    final result = <String, double>{};
    final now = DateTime.now();

    //cycle through days and extract calories from each meal slot in those days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _fmtDate(date);
      double dayTotal = 0.0;
      for (final slot in MealSlot.values) {
        final key = 'meals:${widget.username}:$dateStr:${slot.name}';
        final raw = prefs.getString(key);

        if (raw != null) {
          try {
            final list = jsonDecode(raw) as List<dynamic>;
            final entries = list
                .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
                .toList();
            dayTotal += entries
                .where((e) => e.hasNutritionData)
                .fold(0.0, (sum, e) => sum + e.scaledCalories);
          } catch (_) {
            // skip slot, treat as 0
          }
        }
      }
      result[dateStr] = dayTotal;
    }
    return result;
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double get _netDeficit => _totalBurned - _totalConsumed;
  double get _weightChange => _netDeficit / _kcalPerKg;

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Weekly Data'));
    final provider = context.watch<DataProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    //if page NOT initialized properly, then display error message and reattempt initializing
    if (_initError != null) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 8),
              const Text('Could not load data.'),
              TextButton(
                onPressed: () {
                  setState(() {
                    _initError = null;
                    _initialized = false;
                  });
                  _init();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    //if not initialized, show loading
    if (!_initialized) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    print(provider.totalConsumed);
    //if mounted and initialized show the page to the user
    return Scaffold(
      appBar: appBar,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _WeightPredictionCard(
            totalConsumed: provider.totalConsumed,
            totalBurned: provider.totalBurned,
            netDeficit: provider.netDeficit,
            weightChange: provider.weightChange,
          ),
          CaloriesBarChart(data: provider.caloriesBtwTwoDates),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.pop(context, "home"),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              color: AppColors.accent, //active tab
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.menu_book),
              onPressed: () => Navigator.pop(context, "meal"),
            ),
          ],
        ),
      ),
    );
  }
}

//card widget for displying the weight change prediction
class _WeightPredictionCard extends StatelessWidget {
  const _WeightPredictionCard({
    required this.totalConsumed,
    required this.totalBurned,
    required this.netDeficit,
    required this.weightChange,
  });

  final double totalConsumed;
  final double totalBurned;
  final double netDeficit;
  final double weightChange;

  @override
  Widget build(BuildContext context) {
    final noChange = weightChange.abs() < 0.005; // rounds to 0.00 kg

    //depending upon change trend display positive or negative trend indicator
    final isLoss = weightChange >= 0;
    final color =
        noChange ? AppColors.muted : (isLoss ? AppColors.accent : AppColors.danger);
    final icon = noChange
        ? Icons.trending_flat
        : (isLoss ? Icons.trending_down : Icons.trending_up);
    final directionLabel = noChange
        ? 'No change'
        : (isLoss ? 'Weight loss' : 'Weight gain');

    //produces the body of the widget from read data
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WEEKLY SUMMARY', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          //arc gauge: consumed vs burned, net deficit in the middle
          Center(
            child: _DeficitRing(
              consumed: totalConsumed,
              burned: totalBurned,
              netDeficit: netDeficit,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            'Calories consumed',
            '${totalConsumed.toStringAsFixed(0)} kcal',
          ),
          _InfoRow('Calories burned', '${totalBurned.toStringAsFixed(0)} kcal'),
          const Divider(height: 20),
          Row(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    directionLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '~${weightChange.abs().toStringAsFixed(2)} kg this week',
                    style: displayNumber(size: 26, color: color),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//270° arc gauge showing calories consumed as a fraction of calories burned
class _DeficitRing extends StatelessWidget {
  const _DeficitRing({
    required this.consumed,
    required this.burned,
    required this.netDeficit,
    required this.color,
  });

  final double consumed;
  final double burned;
  final double netDeficit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction =
        burned > 0 ? (consumed / burned).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: 190,
      height: 190,
      child: CustomPaint(
        painter: _RingPainter(fraction: fraction, color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${netDeficit >= 0 ? '' : '+'}${netDeficit.abs().toStringAsFixed(0)}',
                style: displayNumber(size: 44, color: color),
              ),
              Text(
                netDeficit >= 0 ? 'KCAL DEFICIT' : 'KCAL SURPLUS',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    const startAngle = 3 * math.pi / 4; //bottom-left, 270° sweep
    const maxSweep = 3 * math.pi / 2;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.outline;
    canvas.drawArc(arcRect, startAngle, maxSweep, false, track);

    if (fraction > 0) {
      final fill = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(arcRect, startAngle, maxSweep * fraction, false, fill);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}

//displays information in a row inside _WeightPredictionWidget
class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
