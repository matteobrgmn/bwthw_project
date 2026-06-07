//food item handler for database hits
class FoodSearchHit {
  //food identifiers
  final int fdcId;
  final String description;
  final String dataType;

  const FoodSearchHit({
    required this.fdcId,
    required this.description,
    required this.dataType,
  });

  //parsing from JSON
  factory FoodSearchHit.fromJson(Map<String, dynamic> json) {
    return FoodSearchHit(
      fdcId: json['fdcId'] as int,
      description: json['description'] as String,
      dataType: json['dataType'] as String,
    );
  }
}
