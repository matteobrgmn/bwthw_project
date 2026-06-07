//JSON database response structure, requires id, description and nutrients
const Map<String, dynamic> kUsdaFoodSchema = {
  r'$schema': 'http://json-schema.org/draft-07/schema#',
  'title': 'USDA Food Detail Response',
  'type': 'object',
  'required': ['fdcId', 'description', 'foodNutrients'],
  'additionalProperties': true,
  'properties': {
    'fdcId': {'type': 'integer'},
    'description': {'type': 'string'},
    'dataType': {'type': 'string'},
    'foodNutrients': {
      'type': 'array',
      'items': {
        'type': 'object',
        'required': ['nutrient', 'amount'],
        'additionalProperties': true,
        'properties': {
          'nutrient': {
            'type': 'object',
            'required': ['name'],
            'additionalProperties': true,
            'properties': {
              'name': {'type': 'string'},
              'unitName': {'type': 'string'},
            },
          },
          'amount': {'type': 'number'},
        },
      },
    },
    'foodPortions': {
      'type': 'array',
      'items': {
        'type': 'object',
        'additionalProperties': true,
        'properties': {
          'modifier': {'type': 'string'},
          'gramWeight': {'type': 'number'},
        },
      },
    },
  },
};
