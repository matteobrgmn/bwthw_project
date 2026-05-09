import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

/* This class manages the communication with impact database */
class Impact{
  static final _baseUrl = "https://impact.dei.unipd.it/bwthw/";
  static final _tokenUrl = "gate/v1/token/";
  static final _pingUrl = "gate/v1/ping/";
  static final _refreshUrl = "gate/v1/refresh/";
  static final _formattedPingUrl = Uri.parse(_baseUrl + _pingUrl);
  static final _formattedTokenUrl = Uri.parse(_baseUrl + _tokenUrl);
  static final _formattedRefreshUrl = Uri.parse(_baseUrl + _refreshUrl);
  static final _username = 'i1nyvHLHUd';
  static final _password = '12345678!';
  static String patientUsername = 'Jpefaq6m58';
  static final _stepsSingleDayUrl = "data/v1/steps/patients/$patientUsername/day/";
  static String _token = 'empty';
  static String _refresh = 'empty';

  /* Server status */
  Future<String> serverStatus () async {
    try {
      final responsePing = await http.get(_formattedPingUrl);
      if (responsePing.statusCode == 200) {
      return 'online';
    } else {
      return 'offline';
    }} catch (e) {
    print('Network error: $e');
    return 'offline';
  }
  }

  /* Authentication */
  Future<String> authentication () async {
    final responseAuthenticate = await http.post(_formattedTokenUrl, 
        headers: {
                    'Content-Type': 'application/json',
                  },     
       body: jsonEncode({ 
                          'username' : _username,
                          'password' : _password
                      }));
    if (responseAuthenticate.statusCode == 200) {
      final data = jsonDecode(responseAuthenticate.body);
      _token = data['access'];
      _refresh = data['refresh'];
      return 'successfull';
    } else {
      return 'failed';
    }
  }

  /* Refresh */
  Future<String> refresh () async {
    final responseRefresh = await http.post(_formattedRefreshUrl, 
        headers: {
                    'Content-Type': 'application/json',
                  },     
       body: jsonEncode({ 
                          'refresh' : _refresh
                      }));
    if (responseRefresh.statusCode == 200) {
      final responseRefreshBody = jsonDecode(responseRefresh.body);
      _token = responseRefreshBody['access'];
      // print('successfull'); // Debug
      return 'successfull';
    } else {
      // print('failed'); // Debug
      return 'failed';
    }
  }

  /* Return steps for a single day given by argument if the operation is successful, otherwise return -1 if the statusCode <> 200 */
  Future<int> getStepsSingleDay(String day) async {
  var numberOfSteps = 0;
  if (JwtDecoder.isExpired(_token)){
    await refresh();
    // print('expired'); // Debug
  };
  
  final response = await http.get(
    Uri.parse(_baseUrl + _stepsSingleDayUrl + day),
    headers: {
      'Authorization': 'Bearer $_token',
    },
  );
  if (response.statusCode == 200) {
    final responseDecoded = jsonDecode(response.body);
    for (var i=0; i<responseDecoded['data']['data'].length; i++) {
      if (responseDecoded['data']['data'][i]['value'] != null) {
        numberOfSteps = numberOfSteps + int.parse(responseDecoded['data']['data'][i]['value']);
      }
    }
    // print(numberOfSteps); // Debug
    return numberOfSteps;
    } else {
    // print(-1); // Debug
    // print(response.statusCode);
    // print(response.body);
    return -1;
  }
}

  /* Printer */
   void printer () {
    print('Refresh $_refresh');
    print('Token $_token');
  }
}