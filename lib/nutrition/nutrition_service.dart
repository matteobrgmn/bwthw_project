import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:bwthw_project/nutrition/models/food_detail.dart';
import 'package:bwthw_project/nutrition/models/food_search_hit.dart';
import 'package:bwthw_project/nutrition/nutrition_exceptions.dart';
import 'package:bwthw_project/nutrition/schema_validator.dart';

//USDA API-communication service. Retrieves query results and manages them, avoids repeated access
class NutritionService {
  //host website
  static const String _host = 'api.nal.usda.gov';

  //accepted hits per query
  static const int _pageSize = 5;

  final http.Client _client;

  //cache, uses normalized strings
  final Map<String, List<FoodSearchHit>> _searchCache = {};

  //cache, uses FDC ID
  final Map<int, FoodDetail> _detailCache = {};

  //can use a default http client if not provided
  NutritionService({http.Client? client}) : _client = client ?? http.Client();

  //disposes of client
  void dispose() => _client.close();

  //search query with a normalized string, returns 5 items and reuses unless changed
  Future<List<FoodSearchHit>> search(String query) async {
    final normalised = query.trim().toLowerCase();
    if (normalised.isEmpty) return [];
    if (_searchCache.containsKey(normalised)) {
      return _searchCache[normalised]!;
    }
    await dotenv.load(fileName: "assets/.env"); //loads API key from .env file
    final apiKey = dotenv.env['USDA_API_KEY'] ?? '';

    //root of request url:https://api.nal.usda.gov/fdc/v1/foods/search?api_key=DEMO_KEY
    final uri = Uri.https(_host, '/fdc/v1/foods/search', {
      'query': normalised,
      'api_key': apiKey,
      'pageSize': '$_pageSize',
      'dataType': 'Foundation,SR Legacy,Branded',
    });

    //attempts connection and throws error if unsuccessful
    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (e) {
      throw NutritionTransportException(cause: e);
    }

    _checkStatus(response);

    //handles JSON response and throws error if unsuccessful
    final Map<String, dynamic> decoded;
    try {
      decoded = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw NutritionTransportException(
        cause: 'Failed to decode USDA search response as JSON: $e',
      );
    }

    try {
      validateOrThrow(decoded, kUsdaSearchJsonSchema);
    } on SchemaValidationException catch (e) {
      throw NutritionSchemaException(e.errors);
    }

    //saves hits to cache and returns
    final hits = (decoded['foods'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(FoodSearchHit.fromJson)
        .toList();
    _searchCache[normalised] = hits;
    return hits;
  }

  //runs similar logic to "search" to obtain 100g macros
  Future<FoodDetail> detail(int fdcId) async {
    if (_detailCache.containsKey(fdcId)) {
      return _detailCache[fdcId]!;
    }

    final apiKey = dotenv.env['USDA_API_KEY'] ?? '';
    final uri = Uri.https(_host, '/fdc/v1/food/$fdcId', {'api_key': apiKey});

    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (e) {
      throw NutritionTransportException(cause: e);
    }

    _checkStatus(response);

    final Map<String, dynamic> decoded;
    try {
      decoded = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw NutritionTransportException(
        cause: 'Failed to decode USDA food detail response as JSON: $e',
      );
    }

    try {
      validateOrThrow(decoded, kUsdaFoodJsonSchema);
    } on SchemaValidationException catch (e) {
      throw NutritionSchemaException(e.errors);
    }

    final foodDetail = FoodDetail.fromJson(decoded);

    _detailCache[fdcId] = foodDetail;
    return foodDetail;
  }

  //evaluates response's status code and throws errors if needed
  void _checkStatus(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return;
      case 401:
        throw const NutritionAuthException();
      case 429:
        throw const NutritionRateLimitException();
      default:
        throw NutritionTransportException(
          cause: 'Unexpected HTTP ${response.statusCode}: ${response.body}',
        );
    }
  }
}
