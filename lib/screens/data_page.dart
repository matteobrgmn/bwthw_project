import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:bwthw_project/theme.dart';
import 'package:bwthw_project/widgets/calories_bar_chart.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'package:bwthw_project/screens/meal_page.dart';
import '../widgets/stat_tile.dart';


class DataPage extends StatefulWidget {
  const DataPage({super.key, required this.username});

  final String username;

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    //if mounted and initialized show the page to the user
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Data'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _WeightPredictionCard(
            totalConsumed: provider.totalConsumed,
            totalBurned: provider.totalBurned,
            netDeficit: provider.netDeficit,
            weightChange: provider.weightChange,
            bmi: double.parse(provider.bmi!),
          ),
          CaloriesBarChart(data: provider.caloriesBtwTwoDates),
          Row(
            children: [
              SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: Icons.monitor_weight,
                  label: 'Weight',
                  value: '${provider.weight}',
                  color: AppColors.accent,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: Icons.height,
                  label: 'Height',
                  value: '${provider.height}',
                  color: AppColors.fat,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: Icons.person,
                  label: 'Gender',
                  value: '${provider.gender}',
                  color: AppColors.fat,
                ),
              ),
              SizedBox(width: 12),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: Icons.trending_up,
                  label: 'BMI',
                  value: '${provider.bmi}',
                  color: AppColors.fat,
                ),
              ),
              SizedBox(width: 12),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: .center,
            children: [
              ElevatedButton(
                onPressed: () {
                  TextEditingController tc = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Change weight'),
                        content: SizedBox(
                          height: 150,
                          width: 300,
                          child: Column(
                            mainAxisAlignment: .start,
                            children: [
                              SizedBox(height: 30),
                              Text('Please input the new weight:'),
                              SizedBox(height: 8),
                              TextField(
                                controller: tc,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Weight',
                                  hintText: 'Enter your weight (Kg)',
                                  prefixIcon: Icon(Icons.monitor_weight),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              if (tc.text.isNotEmpty) {
                                await provider.changeWeight(tc.text);
                                if (context.mounted) Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Fill the form before entering or cancel",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('OK'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text("Report weight change"),
              ),
            ],
          ),
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
            //transfer context to meal page
            IconButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealPage(username: widget.username),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book),
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
    required this.bmi,
  });

  final double totalConsumed;
  final double totalBurned;
  final double netDeficit;
  final double weightChange;

  final double bmi;

  @override
  Widget build(BuildContext context) {
    final noChange = weightChange.abs() < 0.005; // rounds to 0.00 kg

    //depending upon change trend display positive or negative trend indicator
    final isLoss = weightChange >= 0;
    final color = noChange
        ? AppColors.muted
        : (bmi < 20
              ? (isLoss ? AppColors.danger : AppColors.accent)
              : (isLoss ? AppColors.accent : AppColors.danger));
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
    final fraction = burned > 0 ? (consumed / burned).clamp(0.0, 1.0) : 0.0;

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
