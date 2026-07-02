import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:bwthw_project/models.2/werable_data_models/distance.dart';
import 'package:bwthw_project/utils/impact.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:bwthw_project/models.2/werable_data_models/calories.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:bwthw_project/models.2/werable_data_models/steps.dart';

class Impact {
  static String baseUrl = ImpactConfig.baseUrl;
  static String pingEndpoint = ImpactConfig.pingEndpoint;
  static String tokenEndpoint = ImpactConfig.tokenEndpoint;
  static String refreshEndpoint = ImpactConfig.refreshEndpoint;

  static const Duration _timeout = Duration(seconds: 10);
  static const String _fallbackImpactUsername = '5UJpUCxIUn';

  Future<bool> isImpactUp() async {
    final url = Impact.baseUrl + Impact.pingEndpoint;

    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      return response.statusCode == 200;
    } on SocketException {
      return false;
    } on HttpException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  //This method allows to refresh the stored JWT in SharedPreferences
  Future<int> refreshTokens() async {
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final refresh = await PreferenceService.getRefreshToken();
    final username = await PreferenceService.getImpactUsername();

    if (refresh == null) {
      return 401;
    }

    try {
      final response = await http
          .post(Uri.parse(url), body: {'refresh': refresh})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        await PreferenceService.saveImpactSession(
          accessToken: decodedResponse['access'],
          refreshToken: decodedResponse['refresh'],
          username: username ?? _fallbackImpactUsername,
        );
      }

      return response.statusCode;
    } on SocketException {
      return 503;
    } on HttpException {
      return 503;
    } on TimeoutException {
      return 503;
    } on FormatException {
      return 500;
    }
  } //_refreshTokens

  Future<int> getAndStoreTokens(String username, String password) async {
    final url = Impact.baseUrl + Impact.tokenEndpoint;
    final body = {'username': username, 'password': password};

    try {
      final response =
          await http.post(Uri.parse(url), body: body).timeout(_timeout);

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        await PreferenceService.saveImpactSession(
          accessToken: decodedResponse['access'],
          refreshToken: decodedResponse['refresh'],
          username: username,
        );
      }

      return response.statusCode;
    } on SocketException {
      return 503;
    } on HttpException {
      return 503;
    } on TimeoutException {
      return 503;
    } on FormatException {
      return 500;
    }
  } //_getAndStoreTokens

  Future<bool> hasValidSession() async {
    final access = await PreferenceService.getAccessToken();
    if (access == null) {
      return false;
    }

    try {
      if (!JwtDecoder.isExpired(access)) {
        return true;
      }
    } on FormatException {
      await PreferenceService.clearImpactSession();
      return false;
    }

    return await refreshTokens() == 200;
  }

  Future<void> logout() async {
    await PreferenceService.saveLogin(false);
    await PreferenceService.clearImpactSession();
  }

  Future<String?> _authorizedAccessToken() async {
    var access = await PreferenceService.getAccessToken();
    if (access == null) {
      return null;
    }

    bool isExpired = true;
    try {
      isExpired = JwtDecoder.isExpired(access);
    } on FormatException {
      await PreferenceService.clearImpactSession();
      return null;
    }

    if (isExpired) {
      final statusCode = await refreshTokens();
      if (statusCode != 200) {
        return null;
      }
      access = await PreferenceService.getAccessToken();
    }

    return access;
  }

  Future<String> _patientUsername() async {
    return await PreferenceService.getImpactUsername() ??
        _fallbackImpactUsername;
  }

  Future<http.Response?> _getAuthorized(Uri uri) async {
    final access = await _authorizedAccessToken();
    if (access == null) {
      return null;
    }

    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};
    try {
      return await http.get(uri, headers: headers).timeout(_timeout);
    } on SocketException {
      return null;
    } on HttpException {
      return null;
    } on TimeoutException {
      return null;
    }
  }

  Future<List<Calories>> getCaloriesData(DateTime date) async {
    List<Calories> result = [];

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final username = await _patientUsername();
    final url =
        '${Impact.baseUrl}data/v1/calories/patients/$username/day/$formattedDate/';

    final response = await _getAuthorized(Uri.parse(url));
    if (response == null) return result;

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

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final username = await _patientUsername();
    final url =
        '${Impact.baseUrl}data/v1/steps/patients/$username/day/$formattedDate/';

    final response = await _getAuthorized(Uri.parse(url));
    if (response == null) return result;

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

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final username = await _patientUsername();
    final url =
        '${Impact.baseUrl}data/v1/distance/patients/$username/day/$formattedDate/';

    final response = await _getAuthorized(Uri.parse(url));
    if (response == null) return result;

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

} //Impact
