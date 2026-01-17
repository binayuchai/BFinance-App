import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:bfinance/navigation/core_navigation.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/user/api';
  final storage = FlutterSecureStorage();

  //Get token for authenticated requests
  Future<String?> getAccessToken() async {
    // Read the token from secure storage
    final getToken = await storage.read(key: 'access_token');

    if (getToken == null) {
      return null;
    }

    // Check if the token is expired
    print("Access token found: $getToken");

    // If expired, refresh it
    if (JwtDecoder.isExpired(getToken)) {
      print("Token expired → refreshing");

      final refreshed = await refreshToken();
      // If refresh successful, get the new token
      if (refreshed) {
        final newToken = await storage.read(key: 'access_token');
        print("New Access token after refresh: $newToken");
        return newToken;
      }
      // If refresh failed, return null
      return null;
    }
    return getToken;
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

  Future<bool> registerUser(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['token']['access']);
      await storage.write(
        key: 'refresh_token',
        value: data['token']['refresh'],
      );
      return true;
    }
    return false;
  }

  //Login User

  Future<bool> loginUser(String email, String password) async {
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
        value: data['token']['refresh'],
      );
      return true;
    }
    return false;
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
        print("New access token: ${data}");
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
