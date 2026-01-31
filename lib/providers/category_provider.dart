import 'package:bfinance/features/category/data/models/category.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:bfinance/services/category_service.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isLoaded = false;
  int? _selectedCategoryId;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  int? get selectedCategoryId => _selectedCategoryId;
  String? get error => _error;

  void setSelectedCategoryId(int? id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    // if data is already loaded, do not fetch again
    if (_isLoaded || _isLoading) return; // Prevent redundant fetches

    final token = await ApiService().getAccessToken();
    if (token == null) {
      _error = "User not authenticated";
      notifyListeners();
      return; // user not authenticated
    }

    // Set loading state to true and notify listeners
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final category_service = CategoryService();
      print("enter categories with headers:");
      final response = await category_service.getCategories();
      print("Response from getCategories: $response");
      if (response.isNotEmpty) {
        _categories = response;
        print("Fetched categories: $_categories");
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.first.id;
        }
        _isLoaded = true;
        _error = null;
      } else {
        _categories = [];
        _isLoaded = true;
        _error = "No categories found";
      }
    } catch (e) {
      _error = "Error fetching categories: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false; // Set loading state to false after fetch attempt
      notifyListeners();
    }
  }

  // Ensure categories are loaded
  Future<void> ensureLoaded() async {
    await fetchCategories();
  }
}
