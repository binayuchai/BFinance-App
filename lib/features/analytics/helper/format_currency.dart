class ChartHelper {
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return "\$${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "\$${(amount / 1000).toStringAsFixed(1)}K";
    } else {
      return "\$${amount.toStringAsFixed(2)}";
    }
  }
}
