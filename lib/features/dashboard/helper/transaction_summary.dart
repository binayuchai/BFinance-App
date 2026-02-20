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
        print(
          "Processing transaction: ${tx.title}, Amount: ${tx.amount}, Category: ${tx.categoryName}, Date: ${tx.date}",
        );
        String categoryKey =
            (tx.categoryName != null && tx.categoryName!.isNotEmpty)
            ? tx.categoryName!
            : 'Uncategorized'; // Use category name or "Unknown" if null
        data[categoryKey] = (data[categoryKey] ?? 0) + tx.amount;
      }
    }
    print("Final data: $data");

    return data;
  }

  // Method to get weekly expenses
  List<double> get getWeeklyExpenses {
    List<double> weeklyExpense = List.filled(7, 0.0);
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    for (final tx in transactions) {
      final date = DateTime.parse(tx.date); // Parse the date string to DateTime
      if (tx.type == TransactionType.expense && date.isAfter(startOfWeek)) {
        int dayIndex = date.weekday - 1; // converting to 0-based index
        weeklyExpense[dayIndex] += tx.amount;
      }
    }
    return weeklyExpense;
  }

  // Method to get monthly expenses
  List<double> get getMonthlyExpenses {
    List<double> monthlyExpense = List.filled(12, 0.0);
    final currentYear = DateTime.now().year;
    for (final tx in transactions) {
      final date = DateTime.parse(tx.date); // Parse the date string to DateTime
      if (tx.type == TransactionType.expense && date.year == currentYear) {
        int monthIndex = date.month - 1; // converting to 0-based index
        monthlyExpense[monthIndex] += tx.amount;
      }
    }
    return monthlyExpense;
  }
}
