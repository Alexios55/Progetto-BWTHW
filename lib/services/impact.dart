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

  Future<int> refreshTokens() async {
    final url = Impact.baseUrl + Impact.refreshEndpoint;
    final refresh = await PreferenceService.getRefreshToken();

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
          username: ImpactConfig.username,
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
  }

  Future<int> getAndStoreTokens(String username, String password) async {
    final url = Impact.baseUrl + Impact.tokenEndpoint;

    final body = {
      'username': username,
      'password': password,
    };

    try {
      print('Calling TOKEN endpoint: $url');
      print('Username login usato: $username');

      final response =
          await http.post(Uri.parse(url), body: body).timeout(_timeout);

      print('Token status code: ${response.statusCode}');
      print('Token body: ${response.body}');

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
  }

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

    print('Access token presente: ${access != null}');

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
        print('Refresh token fallito. Status code: $statusCode');
        return null;
      }

      access = await PreferenceService.getAccessToken();
    }

    return access;
  }

  Future<String> _patientUsername() async {
    print('Username paziente usato: ${ImpactConfig.patientUsername}');
    return ImpactConfig.patientUsername;
  }

  Future<http.Response?> _getAuthorized(Uri uri) async {
    final access = await _authorizedAccessToken();

    if (access == null) {
      print('Access token nullo: impossibile fare la chiamata');
      return null;
    }

    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $access',
    };

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

    final oneYearAgo = DateTime(date.year - 1, date.month, date.day - 1);
    String formattedDate = DateFormat('yyyy-MM-dd').format(oneYearAgo);

    final username = await _patientUsername();

    final url =
        '${Impact.baseUrl}${ImpactConfig.caloriesEndpoint}$username/day/$formattedDate/';

    print('Calling CALORIES endpoint: $url');

    final response = await _getAuthorized(Uri.parse(url));

    if (response == null) {
      print('Response NULL calories');
      return result;
    }

    print('Calories status code: ${response.statusCode}');
    print('Calories body: ${response.body}');

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      final dataContainer = decodedResponse['data'];

      if (dataContainer == null) return result;
      if (dataContainer is List && dataContainer.isEmpty) return result;
      if (dataContainer is! Map) return result;

      final caloriesField = dataContainer['data'];

      if (caloriesField == null || caloriesField is String) return result;

      final String dataDate = dataContainer['date'].toString();

      List<dynamic> rawCaloriesList = [];

      if (caloriesField is List) {
        rawCaloriesList = caloriesField;
      } else if (caloriesField is Map) {
        rawCaloriesList = [caloriesField];
      }

      for (final caloriesJson in rawCaloriesList) {
        if (caloriesJson is Map<String, dynamic>) {
          result.add(
            Calories.fromJson(
              dataDate,
              caloriesJson,
            ),
          );
        }
      }
    }

    return result;
  }

  Future<List<Steps>> getStepsData(DateTime date) async {
    List<Steps> result = [];

    final oneYearAgo = DateTime(date.year - 1, date.month, date.day - 1);
    String formattedDate = DateFormat('yyyy-MM-dd').format(oneYearAgo);

    final username = await _patientUsername();

    final url =
        '${Impact.baseUrl}${ImpactConfig.stepsEndpoint}$username/day/$formattedDate/';

    print('Calling STEPS endpoint: $url');

    final response = await _getAuthorized(Uri.parse(url));

    if (response == null) {
      print('Response NULL steps');
      return result;
    }

    print('Steps status code: ${response.statusCode}');
    print('Steps body: ${response.body}');

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      final dataContainer = decodedResponse['data'];

      if (dataContainer == null) return result;
      if (dataContainer is List && dataContainer.isEmpty) return result;
      if (dataContainer is! Map) return result;

      final stepsField = dataContainer['data'];

      if (stepsField == null || stepsField is String) return result;

      final String dataDate = dataContainer['date'].toString();

      List<dynamic> rawStepsList = [];

      if (stepsField is List) {
        rawStepsList = stepsField;
      } else if (stepsField is Map) {
        rawStepsList = [stepsField];
      }

      for (final stepJson in rawStepsList) {
        if (stepJson is Map<String, dynamic>) {
          result.add(
            Steps.fromJson(
              dataDate,
              stepJson,
            ),
          );
        }
      }
    }

    return result;
  }

  Future<List<Distance>> getDistanceData(DateTime date) async {
    List<Distance> result = [];

    final oneYearAgo = DateTime(date.year - 1, date.month, date.day - 1);
    String formattedDate = DateFormat('yyyy-MM-dd').format(oneYearAgo);

    final username = await _patientUsername();

    final url =
        '${Impact.baseUrl}${ImpactConfig.distanceEndpoint}$username/day/$formattedDate/';

    print('Calling DISTANCE endpoint: $url');

    final response = await _getAuthorized(Uri.parse(url));

    if (response == null) {
      print('Response NULL distance');
      return result;
    }

    print('Distance status code: ${response.statusCode}');
    print('Distance body: ${response.body}');

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      final dataContainer = decodedResponse['data'];

      if (dataContainer == null) return result;
      if (dataContainer is List && dataContainer.isEmpty) return result;
      if (dataContainer is! Map) return result;

      final distanceField = dataContainer['data'];

      if (distanceField == null || distanceField is String) return result;

      final String dataDate = dataContainer['date'].toString();

      List<dynamic> rawDistanceList = [];

      if (distanceField is List) {
        rawDistanceList = distanceField;
      } else if (distanceField is Map) {
        rawDistanceList = [distanceField];
      }

      for (final distanceJson in rawDistanceList) {
        if (distanceJson is Map<String, dynamic>) {
          result.add(
            Distance.fromJson(
              dataDate,
              distanceJson,
            ),
          );
        }
      }
    }

    return result;
  }
}