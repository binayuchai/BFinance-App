class ChartHelper {
  static String formatCurrency(double amount, String currencyCode) {
    if (amount == 0) return '0';
    final absValue = amount.abs();
    if (absValue >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}K";
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}
