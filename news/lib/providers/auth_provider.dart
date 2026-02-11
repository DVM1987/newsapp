import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isLoadingUser = false;
  String? _token;
  String? _userId; // Added userId
  User? _user;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoadingUser => _isLoadingUser;
  String? get token => _token;
  String? get userId => _userId; // Getter
  User? get user => _user;
  String? get error => _error;

  AuthProvider() {
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('auth_user_id'); // Load userId
    _isLoggedIn = _token != null;
    if (_isLoggedIn) {
      await _fetchUserInfo();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    final response = await _authService.login(email: email, password: password);
    print('AUTH PROVIDER LOGIN RESPONSE: $response');

    if (response['access_token'] != null) {
      _token = response['access_token'];
      _isLoggedIn = true;

      // Try to extract user ID. Adjust path based on actual API response.
      // Common patterns: response['user']['id'], response['data']['id'], or response['id']
      if (response['user'] != null && response['user']['id'] != null) {
        _userId = response['user']['id'].toString();
      } else if (response['data'] != null && response['data']['id'] != null) {
        _userId = response['data']['id'].toString();
      } else if (response['id'] != null) {
        _userId = response['id'].toString();
      } else {
        // Fallback: use email as ID if numeric ID not found
        _userId = email;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      if (_userId != null) {
        await prefs.setString('auth_user_id', _userId!);
      }

      await _fetchUserInfo();

      notifyListeners();
      return true;
    } else {
      _parseError(response, 'Login failed');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    _error = null;
    final response = await _authService.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      address: address,
    );
    print('AUTH PROVIDER REGISTER RESPONSE: $response');

    if (response['id'] != null ||
        response['email'] != null ||
        response['data'] != null) {
      return true;
    } else {
      _parseError(response, 'Registration failed');
      notifyListeners();
      return false;
    }
  }

  void _parseError(Map<String, dynamic> response, String defaultMsg) {
    print('PARSING ERROR FROM RESPONSE: $response');
    if (response['errors'] != null && response['errors'] is Map) {
      // Lấy lỗi đầu tiên từ map errors
      final errors = response['errors'] as Map;
      if (errors.isNotEmpty) {
        final firstErrorList = errors.values.first;
        if (firstErrorList is List && firstErrorList.isNotEmpty) {
          _error = firstErrorList.first.toString();
          print('PARSED ERROR MESSAGE: $_error');
          return;
        }
      }
    }
    _error = response['message'] ?? response['error'] ?? defaultMsg;
    if (_error == 'Unauthorized') {
      _error = 'Email or password is incorrect';
    }
    print('PARSED ERROR MESSAGE (FALLBACK): $_error');
  }

  Future<void> logout() async {
    _token = null;
    _userId = null; // Clear userId
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user_id'); // Remove userId
    _user = null;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_token == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _error = null;
    final response = await _authService.changePassword(
      token: _token!,
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    // Check for success based on typical API response structure or successful status code
    // Check for success based on status code or message content
    if ((response['statusCode'] != null &&
            response['statusCode'] >= 200 &&
            response['statusCode'] < 300) ||
        response['status'] == 'success' ||
        (response['message'] != null &&
            response['message'].toString().toLowerCase().contains('success'))) {
      return true;
    } else {
      _parseError(response, 'Change password failed');
      notifyListeners();
      return false;
    }
  }

  Future<void> _fetchUserInfo() async {
    if (_token == null) return;

    _isLoadingUser = true;
    notifyListeners();

    try {
      final response = await _authService.getUserInfo(_token!);

      if (response['statusCode'] == 401) {
        // Token expired or invalid
        print('Token invalid or expired, logging out.');
        await logout();
        return;
      }

      if (response['id'] != null || response['data'] != null) {
        // Handle different response structures: {id: ...} or {data: {id: ...}}
        final userData = response['data'] ?? response;
        _user = User.fromJson(userData);
      }
    } catch (e) {
      print('Error fetching user info: $e');
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserInfo({
    required String name,
    required String phone,
    required String address,
  }) async {
    if (_token == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoadingUser = true;
    notifyListeners();

    try {
      final response = await _authService.updateUserInfo(
        token: _token!,
        name: name,
        phone: phone,
        address: address,
      );

      if (response['statusCode'] == 200 ||
          response['status'] == 'success' ||
          (response['data'] != null)) {
        // Update local user object immediately or refetch
        // Refetching is safer to ensure sync with server
        await _fetchUserInfo();
        return true;
      } else {
        _parseError(response, 'Update failed');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoadingUser = false;
      notifyListeners();
    }
  }
}
