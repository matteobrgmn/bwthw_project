//manages the food's portion from the json response 
class FoodPortion {

  final String modifier;

  final double gramWeight;

  const FoodPortion({required this.modifier, required this.gramWeight});

  //parser for the USDA db response
  factory FoodPortion.fromJson(Map<String, dynamic> json) {
    return FoodPortion(
      modifier: json['modifier'] as String,
      gramWeight: (json['gramWeight'] as num).toDouble(),
    );
  }
}

class FoodDetail {
  //database ID of the item
  final int fdcId;

  final String description;

  //nutritional facts for 100g of product
  final double calories100g;
  final double protein100g;
  final double carbs100g;
  final double fat100g;

  final List<FoodPortion> portions;

  //mg/ml
  final double density;

  const FoodDetail({
    required this.fdcId,
    required this.description,
    required this.calories100g,
    required this.protein100g,
    required this.carbs100g,
    required this.fat100g,
    required this.portions,
    this.density = 1.0,
  });

  //manages the "unit" or unconventional food amount inputs in the USDA database, macro by macro
  factory FoodDetail.fromJson(Map<String, dynamic> json) {
    final nutrients = (json['foodNutrients'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    double calories = 0.0;
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;

    for (final n in nutrients) {
      final nutrient = n['nutrient'] as Map<String, dynamic>;
      final name = (nutrient['name'] as String).toLowerCase();
      final unitName = ((nutrient['unitName'] ?? '') as String).toLowerCase();
      final amount = (n['amount'] as num).toDouble();

      if (name.contains('energy') && unitName.contains('kcal')) {
        calories = amount;
      } else if (name.contains('protein')) {
        protein = amount;
      } else if (name.contains('carbohydrate')) {
        carbs = amount;
      } else if (name.contains('total lipid')) {
        fat = amount;
      }
    }

    final rawPortions = json['foodPortions'] as List<dynamic>?;
    final portions = (rawPortions ?? [])
        .cast<Map<String, dynamic>>()
        .map(FoodPortion.fromJson)
        .toList();

    return FoodDetail(
      fdcId: json['fdcId'] as int,
      description: json['description'] as String,
      calories100g: calories,
      protein100g: protein,
      carbs100g: carbs,
      fat100g: fat,
      portions: portions,
    );
  }
}
