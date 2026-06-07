//JSON database response structure
const Map<String, dynamic> kUsdaSearchSchema = {
  r'$schema': 'http://json-schema.org/draft-07/schema#',
  'title': 'USDA Food Search Response',
  'type': 'object',
  'required': ['foods'],
  'additionalProperties': true,
  'properties': {
    'foods': {
      'type': 'array',
      'items': {
        'type': 'object',
        'required': ['fdcId', 'description', 'dataType'],
        'additionalProperties': true,
        'properties': {
          'fdcId': {'type': 'integer'},
          'description': {'type': 'string'},
          'dataType': {'type': 'string'},
        },
      },
    },
  },
};
