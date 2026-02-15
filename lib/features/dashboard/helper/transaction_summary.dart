import 'package:bfinance/features/category/category.dart';
import 'package:bfinance/features/dashboard/models/transaction.dart';

class TransactionSummary {
  final double totalIncome;
  final double totalExpenses;
  final List<Transaction> transactions;

  // Constructor to access the fields data
  TransactionSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.transactions,
  });

  double get netBalance => totalIncome - totalExpenses;

  // factory method to create TransactionSummary from a list of transactions
  factory TransactionSummary.fromTransactions(List<Transaction> transactions) {
    double income = 0.0;
    double expenses = 0.0;

    // Calculate total income and expenses

    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else {
        expenses += tx.amount;
      }
    }

    return TransactionSummary(
      totalIncome: income,
      totalExpenses: expenses,
      transactions: transactions,
    );
  }

  /*        
Method for Pie Chart Data
 [Current Month's Expenses by Category]

  */
  Map<String, double> get getPieChartData {
    Map<String, double> data = {};
    DateTime now = DateTime.now();
    for (final tx in transactions) {
      final date = DateTime.parse(tx.date); // Parse the date string to DateTime
      if (tx.type == TransactionType.expense &&
          date.month == now.month &&
          date.year == now.year) {
        data[tx.categoryName] = (data[tx.categoryName] ?? 0) + tx.amount;
      }
    }
    return data;
  }
}
