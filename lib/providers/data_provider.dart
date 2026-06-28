import 'package:flutter/material.dart';
import '/impact/impact.dart';
import '../widgets/steps_bar_chart.dart';
import 'dart:async';

class DataProvider extends ChangeNotifier {
  List<StepData> stepsBtwTwoDates = [];
  List<StepData> stepsLastWeekBtwTwoDates = [];
  int stepsDay = 0;
  int caloriesDay = 0;
  int increaseStepPerc = 0;

  final Impact _impact = Impact();
  bool isLoading = false;
  Timer? _timer;

  Future<void> _loadData() async {
    final today = DateTime.now();

    // Create data format for API CALL
    final yesterday = today.subtract(const Duration(days: 1));
    final sevenDaysAgo = today.subtract(const Duration(days: 7));
    final prevWeekEnd = today.subtract(const Duration(days: 7));
    final prevWeekStart = today.subtract(const Duration(days: 14));

    final todayString = "${today.year.toString().padLeft(4, '0')}-" "${today.month.toString().padLeft(2, '0')}-" "${today.day.toString().padLeft(2, '0')}";
    final yesterdayString = "${yesterday.year.toString().padLeft(4, '0')}-" "${yesterday.month.toString().padLeft(2, '0')}-" "${yesterday.day.toString().padLeft(2, '0')}";
    final sevenDaysAgoString = "${sevenDaysAgo.year.toString().padLeft(4, '0')}-" "${sevenDaysAgo.month.toString().padLeft(2, '0')}-" "${sevenDaysAgo.day.toString().padLeft(2, '0')}";

    final prevWeekEndString = "${prevWeekEnd.year.toString().padLeft(4, '0')}-" "${prevWeekEnd.month.toString().padLeft(2, '0')}-" "${prevWeekEnd.day.toString().padLeft(2, '0')}";
    final prevWeekStartString = "${prevWeekStart.year.toString().padLeft(4, '0')}-" "${prevWeekStart.month.toString().padLeft(2, '0')}-" "${prevWeekStart.day.toString().padLeft(2, '0')}";

    final _stepsBtwDates = await _impact.getStepsBtwTwoDates(sevenDaysAgoString, yesterdayString);
    final _caloriesBtwDates = await _impact.getCaloriesBtwTwoDates(sevenDaysAgoString, yesterdayString);
    final _stepsLastWeekBtwDates = await _impact.getStepsBtwTwoDates(prevWeekStartString, prevWeekEndString);

    stepsDay = await _impact.getStepsSingleDay(yesterdayString);
    caloriesDay =  await _impact.getCaloriesSingleDay(yesterdayString);

    stepsBtwTwoDates = convertToChartData(_stepsBtwDates!);
    stepsLastWeekBtwTwoDates = convertToChartData(_stepsLastWeekBtwDates!);

    double sumSteps(List<StepData> data) {
      double sum = 0;

      for (final item in data) {
        sum += item.value;
      }

      return sum;
    }

    double stepsWeekChange = 0;
    double sumLastWeek = sumSteps(stepsLastWeekBtwTwoDates);
    double sumThisWeek = sumSteps(stepsBtwTwoDates);

    if (sumLastWeek != 0) {
    stepsWeekChange =
        ((sumThisWeek - sumLastWeek) / sumLastWeek) * 100;
    }

    increaseStepPerc = stepsWeekChange.toInt();
    
  }

  Future<void> start() async {
    isLoading = true;
    notifyListeners();

    await _impact.authentication();
    await _loadData();  

    isLoading = false;
    notifyListeners();

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        await _loadData();
        notifyListeners();
      },
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
  
}