class ChartHelper {
  static String formatCurrency(double amount, String currencyCode) {
    if (amount >= 1000000) {
      return "$currencyCode ${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "$currencyCode ${(amount / 1000).toStringAsFixed(1)}K";
    } else {
      return "$currencyCode ${amount.toStringAsFixed(2)}";
    }
  }
}
