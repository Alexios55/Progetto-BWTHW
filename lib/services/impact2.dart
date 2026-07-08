import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:bwthw_project/models.2/werable_data_models/distance.dart';

class Impact {
  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';
  static String impactUsername = '5UJpUCxIUn';

  static String distanceEndpoint = 'data/v1/distance/patients';


  //This method allows to refresh the stored JWT in SharedPreferences
  Future<int> refreshTokens() async {
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');
    if (refresh != null) {
      final body = {'refresh': refresh};
      print('Calling: $url');
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final sp = await SharedPreferences.getInstance();
        await sp.setString('access', decodedResponse['access']);
        await sp.setString('refresh', decodedResponse['refresh']);
      }
      return response.statusCode;
    }
    return 401;
  }

  Future<int> getAndStoreTokens(String username, String password) async {
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};
    print('Calling: $url');
    final response = await http.post(Uri.parse(url), body: body);
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    }
    return response.statusCode;
  }

  
  // Getting distance data — stesso pattern di getHRData
  Future<List<Distance>> getDistanceData(DateTime date) async {
    List<Distance> result = [];
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');
    if (JwtDecoder.isExpired(access!)) {
      await refreshTokens();
      access = sp.getString('access');
    }

    final oneYearAgo = DateTime(date.year - 2, date.month, date.day -1);
    String formattedDate = DateFormat('yyyy-MM-dd').format(oneYearAgo);
    final url =
        '${Impact.baseUrl}data/v1/distance/patients/${Impact.impactUsername}/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};
    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      for (var i = 0; i < decodedResponse['data']['data'].length; i++) {
        result.add(
          Distance.fromJson(
            decodedResponse['data']['date'],
            decodedResponse['data']['data'][i],
          ),
        );
      }
    }
    return result;
  }
} //Impact