import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/user/api';
  final storage = FlutterSecureStorage();

  //Get token for authenticated requests
  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
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
      await storage.write(key: 'access_token', value: data['access']);
      await storage.write(key: 'refresh_token', value: data['refresh']);
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
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['access']);
      await storage.write(key: 'refresh_token', value: data['refresh']);
      return true;
    }
    return false;
  }

  //Refresh Token

  Future<bool> refreshToken() async {
    final refresh = await storage.read(key: 'refresh_token');
    if (refresh == null) return false;

    try {
      // if token is expired, get a new one
      final response = await http.post(
        Uri.parse('$baseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: 'access_token', value: data['access']);
        return true;
      }
      if (response.statusCode == 401 || response.statusCode == 400) {
        // Refresh token is invalid or expired
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'refresh_token');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
    return false;
  }
}
