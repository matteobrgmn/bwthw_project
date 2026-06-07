
library;

//auth in USDA server is not handled
class NutritionAuthException implements Exception {
  final String message;
  const NutritionAuthException([this.message = 'USDA API key is invalid or missing.']);

  @override
  String toString() => 'NutritionAuthException: $message';
}

//rate limit reached
class NutritionRateLimitException implements Exception {
  final String message;

  const NutritionRateLimitException([this.message = 'USDA API rate limit exceeded.']);

  @override
  String toString() => 'NutritionRateLimitException: $message';
}

//transport error or non-200 HTTP code
class NutritionTransportException implements Exception {
  final Object cause;

  const NutritionTransportException({required this.cause});

  @override
  String toString() => 'NutritionTransportException: $cause';
}

//if HTTP request is successful but JSON conversion fails
class NutritionSchemaException implements Exception {
  final List<String> errors;

  const NutritionSchemaException(this.errors);

  @override
  String toString() =>
      'NutritionSchemaException: USDA response failed schema validation — '
      '${errors.join('; ')}';
}
