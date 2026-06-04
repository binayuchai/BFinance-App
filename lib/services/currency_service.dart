import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  // Detect the user's currency based on their location or device settings
  Future<String> detectCurrency() async {
    // JP -> JPY
    // US -> USD
    // IN -> INR

    final countryCode = PlatformDispatcher.instance.locale.countryCode;
    print("Detected country code: $countryCode");
    switch (countryCode) {
      case "JP":
        return "JPY";
      case "US":
        return "USD";
      case "IN":
        return "INR";

      case "GB":
        return "GBP";
      case "CA":
        return "CAD";
      case "AU":
        return "AUD";
      case "NP":
        return "NPR";
      case "DE":
      case "FR":
      case "IT":
      case "ES":
      case "NL":
        return "EUR"; // EU countries using Euro
      default:
        return "USD"; // Default to USD if country code is not recognized
    }
  }

  // Save the user's preferred currency to local storage or backend
  Future<void> saveCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyKey', currencyCode);
  }

  // Fetch the user's preferred currency from local storage or backend
  Future<String?> getSavedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currencyKey');
  }
}
