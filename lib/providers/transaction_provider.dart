import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:bfinance/services/transaction_service.dart';
import 'package:flutter/material.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> transactions = [];
  bool _isLoading = false;
  bool _isLoaded = false;

  List<Transaction> get getTransaction => transactions;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;

  Future<void> fetchTransactions() async {
    if (_isLoaded || _isLoading) return; // Prevent redundant fetches

    _isLoading = true;
    notifyListeners();

    try {} catch (e) {
      debugPrint("Error fetching transactions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
