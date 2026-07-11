import 'package:bfinance/features/settings/account/data/model/user.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/services/api_service.dart';

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
      final data = await _api.getProfile();
      if (data != null) {
        _user = UserModel.fromJson(data);
      }
    } catch (e) {
      _error = e.toString();
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
