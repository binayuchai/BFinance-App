class AmountFormatter {
  static String formatAmount(double amount) {
    return "USD ${amount.toStringAsFixed(2)}";
  }
}
