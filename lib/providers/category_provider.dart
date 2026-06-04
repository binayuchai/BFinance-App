import 'package:bfinance/features/category/data/models/category.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:bfinance/services/category_service.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false; // Track loading state
  bool _isLoaded = false; // Track if categories have been loaded at least once
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

  void resetCategories() {
    _categories = [];
    _isLoaded = false;
    _selectedCategoryId = null;
    _error = null;
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

  // Add a new category and refresh the list
  Future<bool> addCategoryProvider(Category category) async {
    print("Adding category: ${category.name}");
    _isLoading = true; // Set loading state to true while adding category
    _error = null;
    notifyListeners();
    try {
      final category_service = CategoryService();
      final success = await category_service.addCategory(category);
      if (success) {
        // Reset loading state and error before fetching categories
        _isLoaded = false;
        // Refresh the category list
        await fetchCategories();
      } else {
        _error = "Failed to add category";
      }
      return success;
    } catch (e) {
      print("Error adding category: $e");
      _error = "Failed to add category: $e";
      return false;
    } finally {
      _isLoading = false; // Set loading state to false after attempt
      notifyListeners();
    }
  }

  // Ensure categories are loaded
  Future<void> ensureLoaded() async {
    await fetchCategories();
  }

  // Seed default categories
  Future<void> seedDefaultCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify listeners to show loading state

    final defaults = [
      Category(name: "Salary", icon: "salary", type: CategoryType.income),
      Category(name: "Food", icon: "restaurant", type: CategoryType.expense),
      Category(
        name: "Transport",
        icon: "transport",
        type: CategoryType.expense,
      ),
      Category(name: "Rent", icon: "rent", type: CategoryType.expense),
      Category(
        name: "Shopping",
        icon: "shopping_cart",
        type: CategoryType.expense,
      ),
      Category(name: "Health", icon: "health", type: CategoryType.expense),
    ];

    try {
      final service = CategoryService();
      final success = await service.seedCategories(defaults);

      if (success) {
        _isLoaded = false; // Force refresh
        await fetchCategories(); // Fetch updated categories
      } else {
        _error = "Failed to seed some categories";
      }
    } catch (e) {
      _error = "Failed to seed defaults: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing category and refresh the list

  Future<bool> updateCategoryProvider(Category category) async {
    print("Updating category: ${category.name}");
    try {
      final category_service = CategoryService();
      final updatedCategory = await category_service.updateCategory(category);
      if (updatedCategory != null) {
        // Refresh the category list
        final index = _categories.indexWhere(
          (cat) => cat.id == updatedCategory.id,
        );
        if (index != -1) {
          _categories[index] =
              updatedCategory; // Update the category in the list
          notifyListeners();
        }
        return true; // Return true if update was successful
      } else {
        _error = "Failed to update category";
        return false;
      }
    } catch (e) {
      print("Error updating category: $e");
      _error = "Failed to update category: $e";
      return false;
    }
  }

  // Delete a category and refresh the list
  Future<bool> deleteCategoryProvider(int categoryId) async {
    print("Deleteing category with ID: $categoryId");
    try {
      final categoryService = CategoryService();
      final success = await categoryService.deleteCategory(categoryId);
      if (success) {
        // Refresh the category from list
        _categories.removeWhere((cat) => cat.id == categoryId);
        notifyListeners();
        return true;
      } else {
        _error = "Failed to delete category";
        return false;
      }
    } catch (e) {
      print("Error deleting category: $e");
      _error = "Failed to delete category: $e";
      return false;
    }
  }
}
