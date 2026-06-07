import 'package:bwthw_project/nutrition/models/food_detail.dart';

//handling meal unit
enum MealUnit {
  g,
  ml,
  piece,
}

//id for unique identification
int _entryIdCounter = 0;

//single meal entry, includes data inputed from the meal_page
class MealEntry {
  //single meal id
  final String id;

  //picked food
  String foodName;

  //db identifier and picked quantity and unit
  int? fdcId;
  double quantity;
  MealUnit unit;

  //piece entry option
  bool pieceAvailable;

  //macros
  double calories100g;
  double protein100g;
  double carbs100g;
  double fat100g;

  //if portion options are available, saves the grams
  double? firstPortionGrams;

  double density;

  MealEntry({
    required this.id,
    this.foodName = '',
    this.fdcId,
    this.quantity = 0.0,
    this.unit = MealUnit.g,
    this.pieceAvailable = false,
    this.calories100g = 0.0,
    this.protein100g = 0.0,
    this.carbs100g = 0.0,
    this.fat100g = 0.0,
    this.firstPortionGrams,
    this.density = 1.0,
  });

  //handles non-gram units
  double get effectiveGrams {
    switch (unit) {
      case MealUnit.g:
        return quantity;
      case MealUnit.ml:
        return quantity * density;
      case MealUnit.piece:
        return quantity * (firstPortionGrams ?? 100.0);
    }
  }

  //calculates macros based on grams
  double get scaledCalories => calories100g * effectiveGrams / 100.0;
  double get scaledProtein => protein100g * effectiveGrams / 100.0;
  double get scaledCarbs => carbs100g * effectiveGrams / 100.0;
  double get scaledFat => fat100g * effectiveGrams / 100.0;

  //food has been selected and has meaningful nutrition data.
  bool get hasNutritionData =>
      fdcId != null &&
      (calories100g > 0 ||
          protein100g > 0 ||
          carbs100g > 0 ||
          fat100g > 0);

  //reads food detail and sets entry data
  void applyDetail(FoodDetail detail) {
    calories100g = detail.calories100g;
    protein100g = detail.protein100g;
    carbs100g = detail.carbs100g;
    fat100g = detail.fat100g;
    density = detail.density;
    firstPortionGrams =
        detail.portions.isNotEmpty ? detail.portions.first.gramWeight : null;
    pieceAvailable = firstPortionGrams != null;
  }

  //generate a JSON-ready map for sharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'fdcId': fdcId,
      'quantity': quantity,
      'unit': unit.name,
      'pieceAvailable': pieceAvailable,
      'calories100g': calories100g,
      'protein100g': protein100g,
      'carbs100g': carbs100g,
      'fat100g': fat100g,
      'firstPortionGrams': firstPortionGrams,
      'density': density,
    };
  }

  //reads entries from sharedPreferences and produces instances
  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'] as String,
      foodName: json['foodName'] as String? ?? '',
      fdcId: json['fdcId'] as int?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: MealUnit.values.firstWhere(
        (u) => u.name == json['unit'],
        orElse: () => MealUnit.g,
      ),
      pieceAvailable: json['pieceAvailable'] as bool? ?? false,
      calories100g: (json['calories100g'] as num?)?.toDouble() ?? 0.0,
      protein100g: (json['protein100g'] as num?)?.toDouble() ?? 0.0,
      carbs100g: (json['carbs100g'] as num?)?.toDouble() ?? 0.0,
      fat100g: (json['fat100g'] as num?)?.toDouble() ?? 0.0,
      firstPortionGrams: (json['firstPortionGrams'] as num?)?.toDouble(),
      density: (json['density'] as num?)?.toDouble() ?? 1.0,
    );
  }

  //blank entry with a guaranteed-unique id
  factory MealEntry.blank() {
    final counter = ++_entryIdCounter;
    return MealEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_$counter',
    );
  }
}
