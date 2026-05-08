import 'package:http/http.dart' as http;
import 'dart:convert';

/* This class manages the communication with impact database */
class Impact{
  static final _baseUrl = "https://impact.dei.unipd.it/bwthw/";
  static final _tokenUrl = "gate/v1/token/";
  static final _pingUrl = "gate/v1/ping";
  static final _formattedPingUrl = Uri.parse(_baseUrl + _pingUrl);
  static final _formattedTokenUrl = Uri.parse(_baseUrl + _tokenUrl);
  static final _username = 'i1nyvHLHUd';
  static final _password = '12345678!';
  static String? _token;
  static String? _refresh;

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
    final responseAutenticate = await http.post(_formattedTokenUrl, 
        headers: {
                    'Content-Type': 'application/json',
                  },     
       body: jsonEncode({ 
                          'username' : _username,
                          'password' : _password
                      }));
    if (responseAutenticate.statusCode == 200) {
      final data = jsonDecode(responseAutenticate.body);
      _token = data['access'];
      _refresh = data['refresh'];
      return 'successfull';
    } else {
      return 'failed';
    }
  }
  /* Printer */
   void printer () {
    print('Refresh $_refresh');
    print('Token $_token');
  }
}