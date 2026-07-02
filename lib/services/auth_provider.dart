import 'package:bwthw_project/services/impact.dart';
import 'package:bwthw_project/services/preference_service.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({Impact? impact}) : _impact = impact ?? Impact();

  final Impact _impact;

  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _errorMessage;
  String? _username;

  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;
  String? get username => _username;

  Future<void> initialize() async {
    _setLoading(true);

    final shouldRememberSession = await PreferenceService.getLogin();
    if (!shouldRememberSession) {
      _status = AuthStatus.unauthenticated;
      _username = null;
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    final hasSession = await _impact.hasValidSession();
    _status = hasSession ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    _username = hasSession ? await PreferenceService.getImpactUsername() : null;
    _errorMessage = hasSession ? null : 'Session expired. Please sign in again.';
    _setLoading(false);
  }

  Future<bool> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    _errorMessage = null;
    _setLoading(true);

    final statusCode = await _impact.getAndStoreTokens(username, password);

    if (statusCode == 200) {
      await PreferenceService.saveLogin(rememberMe);
      _status = AuthStatus.authenticated;
      _username = username;
      _setLoading(false);
      return true;
    }

    _status = AuthStatus.unauthenticated;
    _errorMessage = _messageForStatus(statusCode);
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    _setLoading(true);
    await _impact.logout();
    _status = AuthStatus.unauthenticated;
    _username = null;
    _errorMessage = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _messageForStatus(int statusCode) {
    if (statusCode == 401) {
      return 'Incorrect username or password.';
    }
    if (statusCode == 503) {
      return 'Impact is unreachable. Check your connection and try again.';
    }
    return 'Login failed (code $statusCode). Please try again.';
  }
}
