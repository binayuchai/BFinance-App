import 'package:bfinance/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:bfinance/features/category/data/models/category.dart';

class CategoryService {
  // final String apiUrl = 'http://127.0.0.1:8000/api/category/';

  // final String apiUrl = 'http://192.168.3.174:8000/api/category/';
  final String apiUrl =
      'https://footpad-oasis-tipped.ngrok-free.dev/api/category/';
  final ApiService api = ApiService();

  // Add methods for fetching and managing categories here

  // GET Categories from API
  Future<List<Category>> getCategories() async {
    // Implementation for fetching categories from API
    try {
      print("Fetching categories from API...");
      final headers = await api.authHeaders();
      final url = Uri.parse(apiUrl);
      print("GET $url with headers: $headers");
      print("Initiating category fetch request...");
      print("URL: $url");
      final response = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print("Request timeout");
              throw TimeoutException('Category fetch request timed out');
            },
          );
      final decoded = jsonDecode(response.body);

      print(decoded.runtimeType);
      print(decoded);

      print("Category fetch response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("Fetched categories: $data");
        print("Mapping categories to Category objects");
        return data.map((e) => Category.fromJson(e)).toList();
      } else {
        print(
          "Failed to fetch categories. Status code: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      print(
        " Entered in the category catch block ,exception occurred while fetching categories:",
      );
      print("Error fetching categories: $e");
      return [];
    }
  }

  // POST Category to API
  Future<bool> addCategory(Category category) async {
    try {
      final headers = await api.authHeaders();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(category.categoryToJson()),
      );
      print("Add category response status: ${response.statusCode}");
      print("Add category response body: ${response.body}");

      if (response.statusCode == 201) {
        print("Category added successfully.");
        return true;
      } else {
        print("Failed to add category. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error adding category: $e");
      return false;
    }
  }

  // Batch seed categories
  Future<bool> seedCategories(List<Category> categories) async {
    try {
      // We run these in parallel for better performance
      final results = await Future.wait(
        categories.map((cat) => addCategory(cat)),
      );
      return results.every((success) => success); // If all succeed, return true
    } catch (e) {
      print("Error seeding categories: $e");
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      final headers = await api.authHeaders();
      final response = await http.put(
        Uri.parse('$apiUrl${category.id}/'),
        headers: headers,
        body: jsonEncode(category.categoryToJson()),
      );
      print("Update category response status: ${response.statusCode}");
      print("Update category response body: ${response.body}");
      if (response.statusCode == 200) {
        print("Category updated successfully.");
        return true;
      } else {
        print("Failed to update category. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating category: $e");
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      final headers = await api.authHeaders();
      final response = await http.delete(
        Uri.parse('$apiUrl$categoryId/'),
        headers: headers,
      );
      print("Delete category response status: ${response.statusCode}");
      print("Delete category response body: ${response.body}");
      if (response.statusCode == 204) {
        print("Category deleted successfully.");
        return true;
      } else {
        print("Failed to delete category. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error deleting category: $e");
      return false;
    }
  }
}
