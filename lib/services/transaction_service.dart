import 'package:bfinance/services/api_service.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../features/dashboard/models/transaction.dart';

class TransactionService {
  final String apiUrl = 'http://127.0.0.1:8000/api/transaction/';
  final ApiService api = ApiService();

  //GET Transactions from API
  Future<List<Transaction>> getTransactions() async {
    try {
      final headers = await api.authHeaders();
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Transaction.fromJson(e)).toList();
      } else {
        print(
          "Failed to fetch transactions. Status code: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      print("Error fetching transactions: $e");
      return [];
    }
  }

  //POST Transaction to API
  Future<bool> addTransaction(Transaction transaction) async {
    try {
      final headers = await api.authHeaders();
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        print("Transaction added successfully.");
        return true;
      } else {
        print("Failed to add transaction. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error adding transaction: $e");
      return false;
    }
  }
}
