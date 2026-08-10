import 'dart:convert';

import 'package:bfinance/features/settings/account/data/model/user.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  //load profile from backend
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.getProfile();
      if (result.data != null) {
        _user = UserModel.fromJson(result.data!);

        //cache the profile data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_profile', jsonEncode(result.data));
        debugPrint("Cached profile data: ${user?.name}");
      } else {
        _error = result.errorMessage ?? "Failed to load profile";
      }
    } catch (e) {
      _error = "An unexpected error occurred";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Update Name(  null = success, String = error message)
  Future<ApiResult> updateName(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.updateProfile({'name': name});
      if (result.success && result.data != null) {
        //update local user model without refetching from backend
        _user = UserModel.fromJson(result.data!);

        // _user = UserModel(
        //   id: _user!.id,
        //   email: _user!.email,
        //   name: name,
        //   defaultCurrency: _user!.defaultCurrency,
        // );
        return ApiResult(success: true, successMessage: result.successMessage);
      }
      return ApiResult(success: false, errorMessage: result.errorMessage);
    } catch (e) {
      return ApiResult(success: false, errorMessage: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //load cached profile from local storage
  Future<void> loadProfileFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_profile');
    if (cachedData != null) {
      try {
        final data = jsonDecode(cachedData);
        _user = UserModel.fromJson(data);
        debugPrint("Loaded cached profile: ${_user!.name}, ${_user!.email}");
        notifyListeners();
      } catch (e) {
        debugPrint("Error decoding cached profile: $e");
      }
    }
  }

  // null = success, String = error message
  Future<ApiResult> changePassword({
    required String oldPassword,
    required String password,
    required String password2,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _api.changePassword(
        oldPassword: oldPassword,
        password: password,
        password2: password2,
      );
      if (result.success) {
        return ApiResult(success: true, successMessage: result.successMessage);
      }
      return ApiResult(success: false, errorMessage: result.errorMessage); //
    } catch (e) {
      return ApiResult(
        success: false,
        errorMessage: e.toString(),
      ); // Return the error message in case of an exception
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //logout
  Future<void> logout() async {
    await _api.logout();
    _user = null;
    notifyListeners();
  }
}
