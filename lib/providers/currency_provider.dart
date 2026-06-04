import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/currency_service.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currencyCode = 'USD'; // Default currency
  final CurrencyService _currencyService = CurrencyService();
  // If the currency is saved in local storage or backend, load it on app startup
  String get currencyCode =>
      _currencyCode; // Getter for the current currency code
  Future<void> initialize() async {
    final savedCurrency = await _currencyService.getSavedCurrency();
    if (savedCurrency != null) {
      _currencyCode = savedCurrency;
    } else {
      // If no saved currency, detect based on location/device settings
      _currencyCode = await _currencyService.detectCurrency();
      await _currencyService.saveCurrency(_currencyCode);
    }
    // String? savedCurrency = await CurrencyService().getSavedCurrency();
    // if (savedCurrency != null) {
    //   _currencyCode = savedCurrency;
    //   notifyListeners();
    // }
    notifyListeners();
  }

  // Save the currency to shared preferences
  Future<void> setCurrency(String newCurrency) async {
    _currencyCode = newCurrency;
    await _currencyService.saveCurrency(newCurrency);
    notifyListeners();
  }
}
