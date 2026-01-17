import 'package:bfinance/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bfinance/features/category/data/models/category.dart';

class CategoryService {
  final String apiUrl = 'http://127.0.0.1:8000/api/category';
  final ApiService api = ApiService();

  // Add methods for fetching and managing categories here

  // GET Categories from API
  Future<List<Category>> getCategories() async {
    // Implementation for fetching categories from API
    try {
      print("Fetching categories from API...");
      final headers = await api.authHeaders();
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
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
}
