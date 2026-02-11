import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://apiforlearning.zendvn.com/api/v2';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    final url = Uri.parse('$baseUrl/users/register');
    print('REGISTER REQUEST URL: $url');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Accept'] = 'application/json';
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['phone'] = phone;
      request.fields['address'] = address;

      print('REGISTER FIELDS: ${request.fields}');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER RESPONSE: ${response.body}');

      return json.decode(response.body);
    } catch (e) {
      print('REGISTER ERROR: $e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    print('LOGIN REQUEST URL: $url');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Accept'] = 'application/json';
      request.fields['email'] = email;
      request.fields['password'] = password;

      print('LOGIN FIELDS: ${request.fields}');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN RESPONSE: ${response.body}');

      return json.decode(response.body);
    } catch (e) {
      print('LOGIN ERROR: $e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse('$baseUrl/auth/change-password');
    print('CHANGE PASSWORD REQUEST URL: $url');
    try {
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'password_current': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      print('CHANGE PASSWORD STATUS: ${response.statusCode}');
      print('CHANGE PASSWORD RESPONSE: ${response.body}');

      final Map<String, dynamic> result = Map<String, dynamic>.from(
        json.decode(response.body) as Map,
      );
      result['statusCode'] = response.statusCode;
      return result;
    } catch (e) {
      print('CHANGE PASSWORD ERROR: $e');
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>> getUserInfo(String token) async {
    final url = Uri.parse('$baseUrl/auth/me');
    print('GET USER INFO REQUEST URL: $url');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('GET USER INFO STATUS: ${response.statusCode}');
      print('GET USER INFO RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'error': 'Failed to fetch user info',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('GET USER INFO ERROR: $e');
      return {'error': e.toString(), 'statusCode': 500};
    }
  }

  Future<Map<String, dynamic>> updateUserInfo({
    required String token,
    required String name,
    required String phone,
    required String address,
  }) async {
    final url = Uri.parse('$baseUrl/auth/update');
    print('UPDATE USER INFO REQUEST URL: $url');
    try {
      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'name': name, 'phone': phone, 'address': address},
      );

      print('UPDATE USER INFO STATUS: ${response.statusCode}');
      print('UPDATE USER INFO RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'error': 'Failed to update user info',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      print('UPDATE USER INFO ERROR: $e');
      return {'error': e.toString(), 'statusCode': 500};
    }
  }
}
