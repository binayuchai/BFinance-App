import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:bfinance/services/transaction_service.dart';
import 'package:flutter/material.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> transactions = [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;

  List<Transaction> get getTransaction => transactions;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  Future<void> fetchTransactions() async {
    if (_isLoaded || _isLoading) return; // Prevent redundant fetches
    final token = await ApiService().getAccessToken();
    if (token == null) {
      _error = "User not authenticated";
      notifyListeners();
      return; // user not authenticated
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final transactionService = TransactionService();
      final response = await transactionService.getTransactions();

      if (response.isNotEmpty) {
        transactions = response;
        _isLoaded = true;
        _isLoading = false;
        _error = null;
      } else {
        transactions = [];
        _isLoaded = true;
        _isLoading = false;
        _error = "No transactions found";
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new transaction and refresh the list
  Future<bool> addTransactionProvider(Transaction tx) async {
    try {
      final transactionService = TransactionService();
      final success = await transactionService.addTransaction(tx);

      if (success) {
        // Refresh the transaction list
        transactions.insert(0, tx);
        notifyListeners();
      }
      return true;
    } catch (e) {
      {
        _error = "Failed to add the transaction $e";
        notifyListeners();
        return false;
      }
    }
  }
}
