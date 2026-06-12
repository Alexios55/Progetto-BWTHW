import 'dart:convert';
import 'dart:io';
import 'package:bwthw_project/models.2/werable_data_models/distance.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:bwthw_project/models.2/werable_data_models/calories.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:bwthw_project/models.2/werable_data_models/steps.dart';

class Impact {
  static String baseUrl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndpoint = 'gate/v1/ping/';
  static String tokenEndpoint = 'gate/v1/token/';
  static String refreshEndpoint = 'gate/v1/refresh/';

  static String impactUsername = '5UJpUCxIUn';
  static String password = '<12345678!>';

  //This method allows to refresh the stored JWT in SharedPreferences
  Future<int> refreshTokens() async {
    //Create the request
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');
    if (refresh != null) {
      final body = {'refresh': refresh};

      //Get the response
      print('Calling: $url');
      final response = await http.post(Uri.parse(url), body: body);

      //If the response is OK, set the tokens in SharedPreferences to the new values
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final sp = await SharedPreferences.getInstance();
        await sp.setString('access', decodedResponse['access']);
        await sp.setString('refresh', decodedResponse['refresh']);
      } //if

      //Just return the status code
      return response.statusCode;
    }
    return 401;
  } //_refreshTokens

  Future<int> getAndStoreTokens(String username, String password) async {
    //Create the request
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};

    //Get the response
    print('Calling: $url');
    final response = await http.post(Uri.parse(url), body: body);

    //If response is OK, decode it and store the tokens. Otherwise do nothing.
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    } //if

    //Just return the status code
    return response.statusCode;
  } //_getAndStoreTokens

  Future<List<Calories>> getCaloriesData(DateTime date) async {
    List<Calories> result = [];

    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    //If access token is expired, refresh it
    if (JwtDecoder.isExpired(access!)) {
      await refreshTokens();
      access = sp.getString('access');
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url =
        '${Impact.baseUrl}data/v1/calories/patients/${Impact.impactUsername}/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      for (var i = 0; i < decodedResponse['data']['data'].length; i++) {
        result.add(
          Calories.fromJson(
            decodedResponse['data']['date'],
            decodedResponse['data']['data'][i],
          ),
        );
      } //for
    }
    return result;
  } //get calories

  // Getting steps data
  Future<List<Steps>> getStepsData(DateTime date) async {
    List<Steps> result = [];

    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    //If access token is expired, refresh it
    if (JwtDecoder.isExpired(access!)) {
      await refreshTokens();
      access = sp.getString('access');
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url =
        '${Impact.baseUrl}data/v1/steps/patients/${Impact.impactUsername}/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    print('Calling: $url');
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      for (var i = 0; i < decodedResponse['data']['data'].length; i++) {
        result.add(
          Steps.fromJson(
            decodedResponse['data']['date'],
            decodedResponse['data']['data'][i],
          ),
        );
      } //for
    }
    return result;
  }

  // Getting distance data
  Future<List<Distance>> getDistanceData(DateTime date) async {
    List<Distance> result = [];

    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    //If access token is expired, refresh it
    if (JwtDecoder.isExpired(access!)) {
      await refreshTokens();
      access = sp.getString('access');
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
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
      } //for
    }
    return result;
  }

}//Impact

  