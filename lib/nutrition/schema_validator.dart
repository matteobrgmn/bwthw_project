import 'package:json_schema/json_schema.dart';

import 'package:bwthw_project/nutrition/schemas/usda_food_schema.dart';
import 'package:bwthw_project/nutrition/schemas/usda_search_schema.dart';

export 'package:bwthw_project/nutrition/schemas/usda_food_schema.dart';
export 'package:bwthw_project/nutrition/schemas/usda_search_schema.dart';

final JsonSchema kUsdaSearchJsonSchema = JsonSchema.create(kUsdaSearchSchema); //debug

final JsonSchema kUsdaFoodJsonSchema = JsonSchema.create(kUsdaFoodSchema); //debug

//validates data against schema, otherwise throws custom error
void validateOrThrow(Map<String, dynamic> data, JsonSchema schema) {
  final results = schema.validate(data);
  if (!results.isValid) {
    final messages = results.errors.map((e) => e.toString()).toList();
    throw SchemaValidationException(messages);
  }
}

//returned error in case of mismatch
class SchemaValidationException implements Exception {
  //list of error strings
  final List<String> errors;

  const SchemaValidationException(this.errors);
  @override
  String toString() => 'SchemaValidationException: ${errors.join('; ')}';
}
