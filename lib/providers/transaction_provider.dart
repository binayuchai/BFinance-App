import 'package:bfinance/features/transaction/helper/transaction_summary.dart';
import 'package:bfinance/features/transaction/models/transaction.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:bfinance/services/transaction_service.dart';
import 'package:flutter/material.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> transactions = [];
  bool _isLoading = false;
  bool _isLoaded =
      false; // To track if transactions have been loaded at least once
  String? _error;

  List<Transaction> get getTransaction => transactions;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  // getter for total summary of transactions
  TransactionSummary get summary =>
      TransactionSummary.fromTransactions(transactions);

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
      final savedTx = await transactionService.addTransaction(tx);

      if (savedTx != null) {
        // Refresh the transaction list
        transactions.insert(0, savedTx);
        notifyListeners();
        return true;
      }
      return false; // API failed to save the transaction
    } catch (e) {
      {
        _error = "Failed to add the transaction $e";
        notifyListeners();
        return false;
      }
    }
  }

  //Edit an existing transaction and refresh the list
  Future<bool> editTransactionProvider(Transaction tx) async {
    try {
      final transactionService = TransactionService();
      final updatedTx = await transactionService.updateTransaction(tx);
      if (updatedTx != null) {
        //Find and replace the transaction in the list
        final index = transactions.indexWhere((t) => t.id == tx.id);
        if (index != -1) {
          transactions[index] = updatedTx;
          notifyListeners();
        }
        return true;
      }
      return false; // API returned error status
    } catch (e) {
      _error = "Failed to edit the transaction $e";
      notifyListeners();
      return false;
    }
  }

  // Delete a transaction and refresh the list
  Future<bool> deleteTransactionProvider(int id) async {
    try {
      final transactionService = TransactionService();
      final success = await transactionService.deleteTransaction(id);
      if (success) {
        //Remove the transaction from the list
        transactions.removeWhere((t) => t.id == id);
        notifyListeners();
        return true;
      }
      return false; // API returned error status
    } catch (e) {
      _error = "Failed to delete the transaction $e";
      notifyListeners();
      return false;
    }
  }
}
