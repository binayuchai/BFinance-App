import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:bfinance/navigation/core_navigation.dart';

class ApiResult {
  final bool success;
  final String? errorMessage;

  ApiResult({required this.success, this.errorMessage});
}

class ApiService {
  // final String baseUrl = 'http://127.0.0.1:8000/user/api';
  // final String baseUrl = 'http://192.168.3.174:8000/user/api';
  final String baseUrl = 'https://footpad-oasis-tipped.ngrok-free.dev/user/api';
  final storage = FlutterSecureStorage();

  //Get token for authenticated requests
  Future<String?> getAccessToken() async {
    final getToken = await storage.read(key: 'access_token');

    // handle null OR empty
    if (getToken == null || getToken.isEmpty) {
      return null;
    }

    print("Access token found: $getToken");

    try {
      // safe decode
      if (JwtDecoder.isExpired(getToken)) {
        print("Token expired → refreshing");

        final refreshed = await refreshToken();

        if (refreshed) {
          final newToken = await storage.read(key: 'access_token');
          print("New Access token after refresh: $newToken");
          return newToken;
        }

        return null;
      }

      return getToken;
    } catch (e) {
      // THIS handles FormatException
      print("JWT decode error: $e");

      // clear bad token
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');

      return null;
    }
  }

  Future<Map<String, String>> authHeaders() async {
    final token = await getAccessToken();
    if (token == null) {
      await logout();
      throw Exception('No valid access token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  //Register User

  Future<ApiResult> registerUser(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': username,
        'email': email,
        'password': password,
        'password2': confirmPassword,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['token']['access']);
      await storage.write(
        key: 'refresh_token',
        value: data['token']['refresh'] ?? '',
      );
      return ApiResult(success: true);
    } else {
      final errorMessage = _parseErrorMessage(
        response.body,
        context: "Register",
      );
      return ApiResult(success: false, errorMessage: errorMessage);
    }
  }

  //Login User

  Future<ApiResult> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print("Response during login: $response");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['token']['access']);
      await storage.write(
        key: 'refresh_token',
        value: data['token']['refresh'] ?? '',
      );

      return ApiResult(success: true);
    } else {
      // Parse error message from backend response
      final errorMessage = _parseErrorMessage(response.body, context: "Login");
      return ApiResult(success: false, errorMessage: errorMessage);
    }
  }

  /// Parses error messages from Django REST Framework responses

  String _parseErrorMessage(String responseBody, {String context = "Login"}) {
    try {
      final errorData = jsonDecode(responseBody);

      // 1. Direct error message
      if (errorData.containsKey('error')) {
        return errorData['error'];
      }

      // 2. Field-specific validation errors - user friendly
      final fieldLabels = {
        'email': 'Email',
        'password': 'Password',
        'username': 'Username',
      };

      for (final field in fieldLabels.keys) {
        if (errorData.containsKey(field) &&
            errorData[field] is List &&
            errorData[field].isNotEmpty) {
          final label = fieldLabels[field];
          final error = errorData[field][0];

          // Make it conversational
          if (error.toString().toLowerCase().contains('required')) {
            return 'Please enter your $label.';
          }
          if (error.toString().toLowerCase().contains('exists') ||
              error.toString().toLowerCase().contains('taken')) {
            return 'This $label is already taken. Try another one.';
          }
          if (error.toString().toLowerCase().contains('valid')) {
            return 'Please enter a valid $label.';
          }
          if (error.toString().toLowerCase().contains('short') ||
              error.toString().toLowerCase().contains('length')) {
            return '$label is too short. Must be at least 8 characters.';
          }
          if (error.toString().toLowerCase().contains('common')) {
            return 'That password is too common. Please choose a stronger one.';
          }
          if (error.toString().toLowerCase().contains('numeric')) {
            return 'Password cannot be entirely numbers.';
          }

          // fallback with label
          return '$label: $error';
        }
      }

      // 3. Non-field errors
      if (errorData.containsKey('non_field_errors') &&
          errorData['non_field_errors'] is List &&
          errorData['non_field_errors'].isNotEmpty) {
        final error = errorData['non_field_errors'][0].toString().toLowerCase();
        if (error.contains('credentials') || error.contains('invalid')) {
          return 'Wrong email or password. Please try again.';
        }
        return errorData['non_field_errors'][0];
      }

      // 4. Catch-all
      // 4. Catch-all
      for (final key in errorData.keys) {
        // Make key readable
        final fieldName =
            key[0].toUpperCase() +
            key
                .substring(1)
                .replaceAll('_', ' '); // "password_errors" → "Password errors"

        if (errorData[key] is List && errorData[key].isNotEmpty) {
          final error = errorData[key][0].toString().toLowerCase();

          if (error.contains('required')) {
            return 'Please enter your $fieldName.';
          }
          if (error.contains('valid')) {
            return 'Please enter a valid $fieldName.';
          }
          if (error.contains('exists') || error.contains('taken')) {
            return '$fieldName is already taken. Try another.';
          }
          if (error.contains('short') || error.contains('length')) {
            return '$fieldName is too short.';
          }

          return '$fieldName: ${errorData[key][0]}';
        }

        if (errorData[key] is String && errorData[key].isNotEmpty) {
          final error = errorData[key].toString().toLowerCase();

          if (error.contains('required')) {
            return 'Please enter your $fieldName.';
          }
          if (error.contains('valid')) {
            return 'Please enter a valid $fieldName.';
          }

          return '$fieldName: ${errorData[key]}';
        }
      }

      // 5. Generic fallback
      return context == "Login"
          ? 'Wrong email or password. Please try again.'
          : 'Registration failed. Please check your details and try again.';
    } catch (e) {
      return context == "Login"
          ? 'Something went wrong. Please try again.'
          : 'Could not create account. Please try again.';
    }
  }
  //Refresh Token

  Future<bool> refreshToken() async {
    final refresh = await storage.read(key: 'refresh_token');
    if (refresh == null) return false;
    print("Refreshing token with refresh token: $refresh");

    try {
      // if token is expired, get a new one
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );
      print("Refresh token entered: $response");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("New access token: $data");
        await storage.write(key: 'access_token', value: data['access']);
        print("Token refreshed successfully.");
        return true;
      }
      if (response.statusCode == 401 || response.statusCode == 400) {
        // Refresh token is invalid or expired
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'refresh_token');
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
    return false;
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}
