import 'package:bfinance/services/exchange_rate_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmountFormatter {
  // static final ExchangeRateService _exchangeRateService = ExchangeRateService();
  //Async version with conversion
  // static Future<String> formatAmount(
  //   double amount, {
  //   required String fromCurrency,
  //   required String displayCurrency,
  // }) async {
  //   final converted = await _exchangeRateService.convert(
  //     amount,
  //     from: fromCurrency,
  //     to: displayCurrency,
  //   );
  //   return "$displayCurrency ${converted.toStringAsFixed(2)}";
  // }

  //sync version when no conversion needed
  static String formatAmountSync(double amount, String currencyCode) {
    return "$currencyCode ${amount.toStringAsFixed(2)}";
  }
}
