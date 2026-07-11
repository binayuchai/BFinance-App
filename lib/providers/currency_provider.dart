import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/currency_service.dart';
import '../services/api_service.dart';
import '../services/exchange_rate_service.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currencyCode = 'USD'; // Default currency
  final CurrencyService _currencyService = CurrencyService();
  final ApiService _apiService = ApiService();
  final ExchangeRateService _exchangeRateService =
      ExchangeRateService(); // ← add this

  // If the currency is saved in local storage or backend, load it on app startup
  String get currencyCode =>
      _currencyCode; // Getter for the current currency code
  Future<void> initialize() async {
    //declaring the flag to prevent multiple initializations due to not reactive nature of fetched cachedCurreny
    bool resolvedCurrency = false;
    //load from cache immediately to avoid delay(fast,offline access)
    final cachedCurrency = await _currencyService.getSavedCurrency();
    if (cachedCurrency != null) {
      _currencyCode = cachedCurrency;
      notifyListeners();
    }
    //Try to sync from backend if user is logged in and has a saved preference
    try {
      final profile = await _apiService.getProfile();
      if (profile != null && profile.containsKey('default_currency')) {
        _currencyCode = profile['default_currency'];
        await _currencyService.saveCurrency(_currencyCode);
        resolvedCurrency = true; // Set flag to true
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching currency from backend: $e");
    }
    // If no saved currency on cache and backend, detect based on location/device settings
    if (cachedCurrency == null && !resolvedCurrency) {
      _currencyCode = await _currencyService.detectCurrency();
      await _currencyService.saveCurrency(_currencyCode);
      notifyListeners();
    }

    // String? cachedCurrency = await CurrencyService().getSavedCurrency();
    // if (cachedCurrency != null) {
    //   _currencyCode = cachedCurrency;
    //   notifyListeners();
    // }
  }

  //Convert amount
  Future<double> convertAmount(double amount, String fromCurrency) async {
    return await _exchangeRateService.convert(
      amount,
      from: fromCurrency,
      to: _currencyCode,
    );
  }

  // Save the currency to shared preferences
  Future<String?> setCurrency(String newCurrency) async {
    try {
      final result = await _apiService.updateProfile({
        'default_currency': newCurrency,
      }); // Sync with backend

      if (result.success) {
        _currencyCode = newCurrency;
        await _currencyService.saveCurrency(
          newCurrency,
        ); // Save to local storage
        notifyListeners();
        return null; // Indicate success
      } else {
        //if backend update fails, we don't update to local
        return result.errorMessage ??
            "Failed to update currency. Please try again.";
      }
    } catch (e) {
      if (e.toString().contains('No valid access token')) {
        return 'No valid access token';
      }
      return "Network error. Please try again.";
    }
  }
}
