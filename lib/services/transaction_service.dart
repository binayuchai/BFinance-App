import 'package:bfinance/services/api_service.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../features/transaction/models/transaction.dart';

class TransactionService {
  // final String apiUrl = 'http://127.0.0.1:8000/api/transaction/';
  // final String apiUrl = 'http://192.168.3.174:8000/api/transaction/';
  final String apiUrl =
      'https://bfinance-backend.onrender.com/api/transaction/';
  final ApiService api = ApiService();

  //GET Transactions from API
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await api.authorizedRequest(
        (headers) => http.get(Uri.parse(apiUrl), headers: headers),
      );
      print("Status: ${response.statusCode}");
      print("Response body: ${response.body}");
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
  Future<Transaction?> addTransaction(Transaction transaction) async {
    try {
      final response = await api.authorizedRequest(
        (headers) => http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: jsonEncode(transaction.toJson()),
        ),
      );

      print("Status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 201) {
        print("Transaction added successfully.");
        return Transaction.fromJson(jsonDecode(response.body));
      } else {
        print("Failed to add transaction. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error adding transaction: $e");
      return null;
    }
  }

  //PUT Transaction to API
  Future<Transaction?> updateTransaction(Transaction transaction) async {
    try {
      final response = await api.authorizedRequest(
        (headers) => http.put(
          Uri.parse('$apiUrl${transaction.id}/'),
          headers: headers,
          body: jsonEncode(transaction.toJson()),
        ),
      );
      if (response.statusCode == 200) {
        print("Transaction updated successfully.");
        return Transaction.fromJson(jsonDecode(response.body));
      } else {
        print(
          "Failed to update transaction. Status code: ${response.statusCode}  ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("Error updating transaction: $e");
      return null;
    }
  }

  //DELETE Transaction from API
  Future<bool> deleteTransaction(int id) async {
    try {
      final response = await api.authorizedRequest(
        (headers) => http.delete(Uri.parse('$apiUrl$id/'), headers: headers),
      );
      if (response.statusCode == 204) {
        print("Transaction deleted successfully.");
        return true;
      } else {
        print(
          "Failed to delete transaction. Status code: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("Error deleting transaction: $e");
      return false;
    }
  }
}
