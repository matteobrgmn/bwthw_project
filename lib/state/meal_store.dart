import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bwthw_project/nutrition/models/meal_entry.dart';

enum MealSlot {
  breakfast,
  lunch,
  dinner,
  snack,
}


//For checks: key format = `meals:<username>:<YYYY-MM-DD>:<slot>`

class MealStore extends ChangeNotifier {
  MealStore({required SharedPreferences prefs, required String username})
      : _prefs = prefs,
        _username = username;

  final SharedPreferences _prefs;
  final String _username;

  MealSlot currentSlot = MealSlot.breakfast;

  List<MealEntry> _entries = [];
  List<MealEntry> get entries => List.unmodifiable(_entries);

  //keeps wether or not the current last entry still needs to be handled
  bool get isDirty => _isDirty;
  bool _isDirty = false;

  //saves if the slot is dirty, then selects the slot
  Future<void> selectSlot(MealSlot slot) async {
    if (_isDirty) await save();
    currentSlot = slot;
    await load();
    notifyListeners();
  }

  void addRow() {
    _entries.add(MealEntry.blank());
    _isDirty = true;
    notifyListeners();
  }

  void removeRow(String entryId) {
    _entries.removeWhere((e) => e.id == entryId);
    _isDirty = true;
    notifyListeners();
  }

  void updateEntry(String entryId, void Function(MealEntry) updater) {
    final entry = _entries.where((e) => e.id == entryId).firstOrNull;
    if (entry == null) return;
    updater(entry);
    _isDirty = true;
    notifyListeners();
  }

  //saves a meal to a specific slot
  Future<void> save() async {
    final json = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyFor(currentSlot), json);
    _isDirty = false;
  }

  //loads a list from sharedpreferences with the meal entries for a specific date and time
  Future<void> load() async {
    final raw = _prefs.getString(_keyFor(currentSlot));
    if (raw == null) {
      _entries = [];
    } else {
      final list = jsonDecode(raw) as List<dynamic>;
      _entries = list
          .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  //function(s) for macro computation
  double get totalCalories => _entries
      .where((e) => e.hasNutritionData)
      .fold(0.0, (sum, e) => sum + e.scaledCalories);


  double get totalProtein => _entries
      .where((e) => e.hasNutritionData)
      .fold(0.0, (sum, e) => sum + e.scaledProtein);


  double get totalCarbs => _entries
      .where((e) => e.hasNutritionData)
      .fold(0.0, (sum, e) => sum + e.scaledCarbs);


  double get totalFat => _entries
      .where((e) => e.hasNutritionData)
      .fold(0.0, (sum, e) => sum + e.scaledFat);

  //returns the key to retrieve the sharedpreferences meal data by username, date and meal
  String _keyFor(MealSlot slot) {
    final today = DateTime.now();
    final date =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return 'meals:$_username:$date:${slot.name}';
  }
}
