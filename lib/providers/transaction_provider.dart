import 'dart:convert';

import 'package:bfinance/features/transaction/helper/transaction_summary.dart';
import 'package:bfinance/features/transaction/models/transaction.dart';
import 'package:bfinance/providers/currency_provider.dart';
import 'package:bfinance/services/api_service.dart';
import 'package:bfinance/services/notification_service.dart';
import 'package:bfinance/services/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/services/currency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> transactions = [];
  bool _isLoading = false;
  bool _isLoaded =
      false; // To track if transactions have been loaded at least once
  String? _error;
  final Map<int, double> _convertedAmounts = {}; // Cache for exchange rates
  bool _ratesAreStale =
      false; // Flag to indicate if any conversion used stale rates
  bool get ratesAreStale =>
      _ratesAreStale; // Public getter for the stale rates flag

  List<Transaction> get getTransaction => transactions;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  // getter for total summary of transactions
  TransactionSummary get summary =>
      TransactionSummary.fromTransactions(transactions, _convertedAmounts);

  void clear() {
    transactions.clear();
    _convertedAmounts.clear();
    _isLoaded = false;
    _isLoading = false;
    _error = null;
    _ratesAreStale = false;
    notifyListeners();
  }

  Future<void> _persistTransactionsToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cached_transactions',
      jsonEncode(transactions.map((tx) => tx.toJson()).toList()),
    );
  }

  Future<void> fetchTransactions({
    required CurrencyProvider currencyProvider,
    bool forceRefresh = false,
  }) async {
    // forceRefresh bypasses the "already loaded" guard so ensureLoaded can
    // trigger a real background refresh even after the first load.
    if (!forceRefresh && (_isLoaded || _isLoading)) {
      return; // Prevent redundant fetches
    }
    if (_isLoading) return; // still avoid overlapping fetches even when forcing

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

        // Cache the transactions in local storage
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString(
        //   'cached_transactions',
        //   jsonEncode(transactions.map((tx) => tx.toJson()).toList()),
        // );
        await _persistTransactionsToCache();
        debugPrint("Transactions cached successfully. ${transactions.length}");

        //call the converted amount after fetch transactions (since we cached raw amount in cache so we need to convert it to current currency)

        await convertAllAmount(currencyProvider);
      } else {
        transactions = [];
        _isLoaded = true;
        _isLoading = false;
        _error = "No transactions found";
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
      //fallback to cached transactions if available
      // Only needed on cold-start/direct calls where cache hasn't been
      // loaded yet. ensureLoaded already loads cache before calling this
      // with forceRefresh: true, so avoid a redundant double-load there.
      if (!forceRefresh) {
        await loadCachedTransactions(currencyProvider: currencyProvider);
      }
      _error = "Showing old transactions";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new transaction and refresh the list
  Future<bool> addTransactionProvider(
    Transaction tx, {
    required CurrencyProvider currencyProvider,
  }) async {
    try {
      final transactionService = TransactionService();
      final savedTx = await transactionService.addTransaction(tx);

      if (savedTx != null) {
        // Refresh the transaction list
        transactions.insert(0, savedTx);
        //only convert the new transaction amount instead of refetching all transactions
        _convertedAmounts[savedTx.id!] = await currencyProvider.convertAmount(
          savedTx.amount,
          savedTx.currencyCode,
        );
        await _persistTransactionsToCache(); // Update the cache after adding
        notifyListeners();

        //check budget alert after adding
        await _checkBudgetAlert(savedTx, currencyProvider);
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
  Future<bool> editTransactionProvider(
    Transaction tx, {
    required CurrencyProvider currencyProvider,
  }) async {
    try {
      final transactionService = TransactionService();
      final updatedTx = await transactionService.updateTransaction(tx);
      if (updatedTx != null) {
        //Find and replace the transaction in the list
        final index = transactions.indexWhere((t) => t.id == tx.id);
        if (index != -1) {
          transactions[index] = updatedTx;
          //only convert the updated transaction amount instead of refetching all transactions
          _convertedAmounts[updatedTx.id!] = await currencyProvider
              .convertAmount(updatedTx.amount, updatedTx.currencyCode);
          // Persist immediately so a reload reflects the edit
          await _persistTransactionsToCache();
          notifyListeners();
        }
        //check budget alert after editing
        await _checkBudgetAlert(updatedTx, currencyProvider);

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
        // transactions.removeWhere((t) => t.id == id);
        // _convertedAmounts.remove(id);

        // Update the cache
        await _persistTransactionsToCache();
        debugPrint("Transaction deleted and cache updated.");

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

  //load cached transactions from local storage
  Future<void> loadCachedTransactions({
    CurrencyProvider? currencyProvider,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_transactions');
    print("Loading cached transactions: $cachedData");
    if (cachedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(cachedData);
        transactions = jsonList
            .map((json) => Transaction.fromJson(json))
            .toList();
        _isLoaded = true; // Mark as loaded since we have cached data
        debugPrint("✅ Loaded ${transactions.length} transactions from cache");

        if (currencyProvider != null) {
          await convertAllAmount(currencyProvider);
        } else {
          notifyListeners();
        }
      } catch (e) {
        debugPrint("Error loading cached transactions: $e");
      }
    }
  }

  Future<void> ensureLoaded({
    required CurrencyProvider currencyProvider,
  }) async {
    // if (transactions.isNotEmpty) {
    //   return;
    // }
    //try to load from cache first

    //if cache is still empty, fetch from API when we have internet connection

    final token = await ApiService().getAccessToken();
    if (token != null) {
      await fetchTransactions(
        currencyProvider: currencyProvider,
        forceRefresh: true,
      );
    }
    if (transactions.isEmpty) {
      await loadCachedTransactions(currencyProvider: currencyProvider);
    }
  }

  //Call the method after setCurrency or after fetchTransaction
  Future<void> convertAllAmount(CurrencyProvider currencyProvider) async {
    bool anyState = false;
    for (final t in transactions) {
      try {
        final converted = await currencyProvider.convertAmount(
          t.amount,
          t.currencyCode,
        );
        _convertedAmounts[t.id!] = converted;
        if (currencyProvider.lastConversionUsedStaleRate) {
          anyState = true; // If any conversion used stale rates, set the flag
        }
      } catch (e) {
        print("Error converting amount for transaction ${t.id}: $e");
      }
    }
    _ratesAreStale = anyState; // Update the stale rates flag
    notifyListeners(); // Notify listeners after all conversions are done
  }

  //widget reads this
  double getConvertedAmount(int transactionId) {
    return _convertedAmounts[transactionId] ?? 0.0;
  }

  //budget check alert
  Future<void> _checkBudgetAlert(
    Transaction transaction,
    CurrencyProvider currencyProvider,
  ) async {
    //only check for expenses
    if (transaction.isIncome) return;
    final prefs = await SharedPreferences.getInstance();
    final budgetAlertsEnabled = prefs.getBool('notif_budget_alerts') ?? false;
    final pushEnabled =
        prefs.getBool('notif_push') ?? true; //by default is it true

    if (!budgetAlertsEnabled || !pushEnabled) return;
    //calculate total expenses this month
    final now = DateTime.now();
    final currentMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}'; // 2026-09

    //fire alert if exceeds set budget

    //Extracting monthly expense
    final monthlyExpenses = transactions
        .where((t) => !t.isIncome && t.date.startsWith(currentMonth))
        .toList();

    // checking the current total exceed the limit of a month or not
    double monthlyLimit = await currencyProvider.convertAmount(
      1000,
      'USD',
    ); //default
    monthlyLimit = prefs.getDouble('notif_budget_limit') ?? monthlyLimit;

    //Calculating total monthly expenses
    final monthlytotal = monthlyExpenses.fold(0.0, (sum, t) => sum + t.amount);

    //compare monthly limit VS  monthly total
    if (monthlytotal > monthlyLimit) {
      await NotificationService().showBudgetAlert(
        'total', //type of notification
        'total expense',
        monthlytotal, //total amount
        monthlyLimit,
        currencyProvider.currencyCode,
      );
    }

    // check category limit
    final categoryLimit = prefs.getDouble(
      'notif_budget_category_${transaction.categoryId}',
    ); //here no need for default value as fallback

    if (categoryLimit != null) {
      final categoryTotal = monthlyExpenses
          .where((t) => t.categoryId == transaction.categoryId)
          .fold(0.0, (sum, t) => sum + t.amount);
      if (categoryTotal > categoryLimit) {
        await NotificationService().showBudgetAlert(
          'category',
          transaction.category.name,
          categoryTotal,
          categoryLimit,
          currencyProvider.currencyCode,
        );
      }
    }
  }

  // 1. Pure, synchronous, local-only removal — no async work at all
  void removeTransactionLocally(int id) {
    transactions.removeWhere((t) => t.id == id);
    _convertedAmounts.remove(id);
    notifyListeners();
  }

  //Restore if the API delete fails
  void restoreTransactionLocally(
    int index,
    Transaction tx,
    CurrencyProvider currencyProvider,
  ) async {
    final safeIndex = index.clamp(0, transactions.length);
    transactions.insert(safeIndex, tx);
    try {
      _convertedAmounts[tx.id!] = await currencyProvider.convertAmount(
        tx.amount,
        tx.currencyCode,
      );
    } catch (e) {
      debugPrint("Error re-converting restored transaction amount: $e");
    }
    notifyListeners();
  }
}
