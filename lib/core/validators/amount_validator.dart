class AmountValidator {
  static double? validateAndParse(String? value, Function(String) onError) {
    if (value == null || value.isEmpty) {
      onError("Amount is required");
      return null;
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      onError("Please enter a valid number");
      return null;
    }
    if (amount <= 0) {
      onError("Amount must be greater than zero");
      return null;
    }
    // Check for maximum 12 digits including decimals
    final parts = value.split('.');
    final integerPartLength = parts[0].length;
    final decimalPartLength = parts.length > 1 ? parts[1].length : 0;
    if (integerPartLength + decimalPartLength > 12) {
      onError("Amount cannot exceed 12 digits including decimals");
      return null;
    }
    return amount; // valid
  }
}
