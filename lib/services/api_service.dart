import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:bfinance/navigation/core_navigation.dart';

class ApiResult {
  final bool success;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, dynamic>? data;

  ApiResult({
    required this.success,
    this.errorMessage,
    this.successMessage,
    this.data,
  });
}

class ApiService {
  // final String baseUrl = 'http://127.0.0.1:8000/user/api';
  // final String baseUrl = 'http://192.168.3.174:8000/user/api';
  final String baseUrl = 'https://footpad-oasis-tipped.ngrok-free.dev/user/api';
  final storage = FlutterSecureStorage();

  String getFriendlyErrorMessage(Object error) {
    if (error is HandshakeException) {
      return 'Unable to connect securely to the server. Please try again later.';
    }
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (error is TimeoutException) {
      return 'The request took too long. Please try again.';
    }
    if (error is HttpException) {
      return 'The server could not be reached. Please try again later.';
    }
    if (error is FormatException) {
      return 'The server returned an unexpected response. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

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
      await logout(sessionExpired: true);
      throw Exception('No valid access token found');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  //Authorize Requests to API
  Future<http.Response> authorizedRequest(
    Future<http.Response> Function(Map<String, String>) request,
  ) async {
    final headers = await authHeaders();
    final response = await request(headers);
    if (response.statusCode == 401) {
      // Unauthorized - token might be invalid or expired

      await logout(sessionExpired: true);

      throw Exception('Session expired. Please login again.');
    }
    return response;
  }

  //Authorize Request Wrapper for handling errors
  // Future<ApiResult> authorizedRequestWithErrorHandling(
  //   Future<http.Response> Function(Map<String, String>) request,
  // ) async {
  //   try {
  //     final response = await authorizedRequest(request);
  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       try {
  //         final data = jsonDecode(response.body);
  //         return ApiResult(success: true, data: data);
  //       } catch (e) {
  //         return ApiResult(
  //           success: true,
  //           successMessage: 'Request successful but something went wrong.',
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     return ApiResult(
  //       success: false,
  //       errorMessage: getFriendlyErrorMessage(e),
  //     );
  //   }
  // }
  //Register User

  Future<ApiResult> registerUser(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
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
        await storage.write(
          key: 'access_token',
          value: data['token']['access'],
        );
        await storage.write(
          key: 'refresh_token',
          value: data['token']['refresh'] ?? '',
        );
        return ApiResult(success: true);
      } else {
        final errorMessage = _parseErrorMessage(
          response.body,
          // context: "Register",
        );
        return ApiResult(success: false, errorMessage: errorMessage);
      }
    } catch (e) {
      return ApiResult(
        success: false,
        errorMessage: getFriendlyErrorMessage(e),
      );
    }
  }

  //Login User

  Future<ApiResult> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print("Response during login: $response");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(
          key: 'access_token',
          value: data['token']['access'],
        );
        await storage.write(
          key: 'refresh_token',
          value: data['token']['refresh'] ?? '',
        );

        return ApiResult(success: true);
      } else {
        // Parse error message from backend response
        final errorMessage = _parseErrorMessage(
          response.body,
          // context: "Login"
        );
        return ApiResult(success: false, errorMessage: errorMessage);
      }
    } catch (e) {
      return ApiResult(
        success: false,
        errorMessage: getFriendlyErrorMessage(e),
      );
    }
  }

  /// Parses error messages from Django REST Framework responses

  // String _parseErrorMessage(String responseBody, {String context = "Login"}) {
  //   try {
  //     final errorData = jsonDecode(responseBody);

  //     // 1. Direct error message
  //     if (errorData.containsKey('error')) {
  //       return errorData['error'];
  //     }

  //     // 2. Field-specific validation errors - user friendly
  //     final fieldLabels = {
  //       'email': 'Email',
  //       'password': 'Password',
  //       'username': 'Username',
  //       'password2': 'Confirm password',
  //       'old_password': 'Current password',
  //     };

  //     for (final field in fieldLabels.keys) {
  //       if (errorData.containsKey(field) &&
  //           errorData[field] is List &&
  //           errorData[field].isNotEmpty) {
  //         final label = fieldLabels[field];
  //         final error = errorData[field][0];

  //         // Make it conversational
  //         if (error.toString().toLowerCase().contains('required')) {
  //           return 'Please enter your $label.';
  //         }
  //         if (error.toString().toLowerCase().contains('incorrect') ||
  //             error.toString().toLowerCase().contains('wrong')) {
  //           return '$label is incorrect. Please try again.';
  //         }
  //         if (error.toString().toLowerCase().contains('match')) {
  //           return 'Passwords do not match.';
  //         }
  //         if (error.toString().toLowerCase().contains('different') ||
  //             error.toString().toLowerCase().contains('same')) {
  //           return 'New password must be different from current password.';
  //         }
  //         if (error.toString().toLowerCase().contains('exists') ||
  //             error.toString().toLowerCase().contains('taken')) {
  //           return 'This $label is already taken. Try another one.';
  //         }
  //         if (error.toString().toLowerCase().contains('valid')) {
  //           return 'Please enter a valid $label.';
  //         }
  //         if (error.toString().toLowerCase().contains('short') ||
  //             error.toString().toLowerCase().contains('length')) {
  //           return '$label is too short. Must be at least 8 characters.';
  //         }
  //         if (error.toString().toLowerCase().contains('common')) {
  //           return 'That password is too common. Please choose a stronger one.';
  //         }
  //         if (error.toString().toLowerCase().contains('numeric')) {
  //           return 'Password cannot be entirely numbers.';
  //         }

  //         // fallback with label
  //         return '$label: $error';
  //       }
  //     }

  //     // 3. Non-field errors
  //     if (errorData.containsKey('non_field_errors') &&
  //         errorData['non_field_errors'] is List &&
  //         errorData['non_field_errors'].isNotEmpty) {
  //       final error = errorData['non_field_errors'][0].toString().toLowerCase();
  //       if (error.contains('credentials') || error.contains('invalid')) {
  //         return 'Wrong email or password. Please try again.';
  //       }
  //       return errorData['non_field_errors'][0];
  //     }

  //     // 4. Catch-all
  //     // 4. Catch-all
  //     for (final key in errorData.keys) {
  //       // Make key readable
  //       final fieldName =
  //           key[0].toUpperCase() +
  //           key
  //               .substring(1)
  //               .replaceAll('_', ' '); // "password_errors" → "Password errors"

  //       if (errorData[key] is List && errorData[key].isNotEmpty) {
  //         final error = errorData[key][0].toString().toLowerCase();

  //         if (error.contains('required')) {
  //           return 'Please enter your $fieldName.';
  //         }
  //         if (error.contains('valid')) {
  //           return 'Please enter a valid $fieldName.';
  //         }
  //         if (error.contains('exists') || error.contains('taken')) {
  //           return '$fieldName is already taken. Try another.';
  //         }
  //         if (error.contains('short') || error.contains('length')) {
  //           return '$fieldName is too short.';
  //         }

  //         return '$fieldName: ${errorData[key][0]}';
  //       }

  //       if (errorData[key] is String && errorData[key].isNotEmpty) {
  //         final error = errorData[key].toString().toLowerCase();

  //         if (error.contains('required')) {
  //           return 'Please enter your $fieldName.';
  //         }
  //         if (error.contains('valid')) {
  //           return 'Please enter a valid $fieldName.';
  //         }

  //         return '$fieldName: ${errorData[key]}';
  //       }
  //     }

  //     // 5. Generic fallback
  //     if (context == "Login") {
  //       return 'Wrong email or password. Please try again.';
  //     } else if (context == "Change Password") {
  //       return 'Failed to change password. Please try again.';
  //     } else {
  //       return 'Registration failed. Please check your details and try again.';
  //     }
  //   } catch (e) {
  //     if (context == "Login") {
  //       return 'Something went wrong. Please try again.';
  //     } else if (context == "Change Password") {
  //       return 'Could not change password. Please try again.';
  //     } else {
  //       return 'Something went wrong. Please try again.';
  //     }
  //   }
  // }

  String _parseErrorMessage(String responseBody) {
    try {
      final errorData = jsonDecode(responseBody);

      // 1. Direct error key
      if (errorData.containsKey('error')) {
        return errorData['error'];
      }

      // 2. All field errors — return first one found
      for (final key in errorData.keys) {
        final value = errorData[key];
        if (value is List && value.isNotEmpty) {
          final msg = value[0].toString();
          // only translate the most common DRF default messages
          if (msg.toLowerCase().contains('blank') ||
              msg.toLowerCase().contains('required')) {
            final fieldName =
                key[0].toUpperCase() + key.substring(1).replaceAll('_', ' ');
            return 'Please enter your $fieldName.';
          }
          return msg; // return backend message directly
        }
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }

      // 3. Generic fallback
      return 'Something went wrong. Please try again.';
    } catch (e) {
      return 'Something went wrong. Please try again.';
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

  Future<void> logout({bool sessionExpired = false}) async {
    //blacklist refresh token on backend
    try {
      final refresh = await storage.read(key: 'refresh_token');
      if (refresh != null && refresh.isNotEmpty) {
        final headers = await authHeaders();
        await http.post(
          Uri.parse('$baseUrl/logout/'),
          headers: headers,
          body: jsonEncode({'refresh': refresh}),
        );
      }
    } catch (_) {
      // blacklist failed (no internet / server down / token already expired)
      // local logout still proceeds — access token expires naturally within 5-15 mins
    }
    //clear snackbars first
    final scaffoldContext = navigatorKey.currentContext;
    if (scaffoldContext != null) {
      ScaffoldMessenger.of(scaffoldContext).clearSnackBars();
    }
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
      arguments: sessionExpired ? 'Session expired. Please login again.' : null,
    );
  }

  //Get user profile
  Future<ApiResult> getProfile() async {
    try {
      final headers = await authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return ApiResult(success: true, data: jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be invalid or expired
        await logout(sessionExpired: true);
        return ApiResult(
          success: false,
          errorMessage: "Session expired. Please login again.",
        );
      } else {
        print(
          "Failed to fetch profile. Status code: ${response.statusCode}, Body: ${response.body}",
        );
        return ApiResult(
          success: false,
          errorMessage: "Failed to fetch profile.",
        );
      }
    } catch (e) {
      print("Error fetching profile: $e");
      return ApiResult(
        success: false,
        errorMessage: getFriendlyErrorMessage(e),
      );
    }
  }

  //Update user profile
  Future<ApiResult> updateProfile(Map<String, dynamic> updatedData) async {
    try {
      final headers = await authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/'),
        headers: headers,
        body: jsonEncode(updatedData),
      );
      if (response.statusCode == 200) {
        return ApiResult(
          success: true,
          successMessage: 'Profile updated successfully.',
          data: jsonDecode(response.body),
        );
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be invalid or expired
        await logout(sessionExpired: true);
        return ApiResult(
          success: false,
          errorMessage: "Session expired. Please login again.",
        );
      } else {
        print(
          "Failed to update profile. Status code: ${response.statusCode}, Body: ${response.body}",
        );
        final errorMessage = _parseErrorMessage(
          response.body,
          // context: "Profile Update",
        );
        return ApiResult(success: false, errorMessage: errorMessage);
      }
    } catch (e) {
      return ApiResult(
        success: false,
        errorMessage: getFriendlyErrorMessage(e),
      );
    }
  }

  //change password
  Future<ApiResult> changePassword({
    required String oldPassword,
    required String password,
    required String password2,
  }) async {
    try {
      final headers = await authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/change-password/'),
        headers: headers,
        body: jsonEncode({
          'old_password': oldPassword,
          'password': password,
          'password2': password2,
        }),
      );
      if (response.statusCode == 200) {
        return ApiResult(
          success: true,
          successMessage: 'Password changed successfully.',
        );
      } else {
        return ApiResult(
          success: false,
          errorMessage: _parseErrorMessage(
            response.body,
            // context: 'Change Password',
          ),
        );
      }
    } catch (e) {
      return ApiResult(
        success: false,
        errorMessage: getFriendlyErrorMessage(e),
      );
    }
  }
}
