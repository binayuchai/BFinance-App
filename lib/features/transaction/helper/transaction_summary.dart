import 'package:bfinance/features/transaction/models/transaction.dart';
import 'package:bfinance/features/category/data/models/category.dart';

class TransactionSummary {
  final double totalIncome;
  final double totalExpenses;
  final List<Transaction> transactions;
  final Map<int, double> convertedAmounts; //  converted amounts

  // Constructor to access the fields data
  TransactionSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.transactions,
    required this.convertedAmounts,
  });

  double get netBalance => totalIncome - totalExpenses;

  // factory method to create TransactionSummary from a list of transactions
  factory TransactionSummary.fromTransactions(
    List<Transaction> transactions,
    Map<int, double> convertedAmounts,
  ) {
    double income = 0.0;
    double expenses = 0.0;

    // Calculate total income and expenses

    for (var tx in transactions) {
      final date = DateTime.parse(tx.date).toLocal();
      final amount =
          convertedAmounts[tx.id] ??
          tx.amount; // Use converted amount if available
      if (tx.category.type == CategoryType.income) {
        income += amount;
      } else if (tx.category.type == CategoryType.expense &&
          date.year == DateTime.now().year) {
        // Only consider expenses for the current year
        expenses += amount;
      }
    }

    return TransactionSummary(
      totalIncome: income,
      totalExpenses: expenses,
      transactions: transactions,
      convertedAmounts: convertedAmounts,
    );
  }

  /*        
Method for Pie Chart Data
 [Current Month's Expenses by Category]

  */
  Map<String, double> get getPieChartData {
    Map<String, double> data = {};
    DateTime now = DateTime.now();
    print("Data of transactions: ${transactions.length}");

    for (final tx in transactions) {
      // API returns date in UTC (e.g. 2026-02-28T11:13:02Z)
      // DateTime.now() is in local timezone (JST).
      // Without toLocal(), month/year comparison may fail near month boundaries.
      final date = DateTime.parse(
        tx.date,
      ).toLocal(); // Parse the date string to DateTime
      final amount =
          convertedAmounts[tx.id] ??
          tx.amount; // Use converted amount if available

      // print("Now: $now  month: ${now.month}  year: ${now.year}");
      // print("Transaction month: ${date.month}  year: ${date.year}");
      // print(
      //   "date of transaction: ${tx.date}, parsed date: $date, category: ${tx.category.name}, amount: ${tx.amount}, type: ${tx.category.type}",
      // );
      if (tx.category.type == CategoryType.expense &&
          date.month == now.month &&
          date.year == now.year) {
        // print(
        //   "Processing transaction: ${tx.title}, Amount: ${tx.amount}, Category: ${tx.category.name}, Date: ${tx.date}",
        // );
        String categoryKey =
            (tx.category.name != null && tx.category.name!.isNotEmpty)
            ? tx.category.name!
            : 'Uncategorized'; // Use category name or "Unknown" if null
        data[categoryKey] = (data[categoryKey] ?? 0) + amount;
        // print(
        //   "Updated category: $categoryKey, Total Amount: ${data[categoryKey]}",
        // );
      }
    }
    print("Final data: $data");

    return data;
  }

  // Method to get weekly expenses
  List<double> get getWeeklyExpenses {
    List<double> weeklyExpense = List.filled(7, 0.0);
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(
      Duration(
        days: now.weekday - 1,
      ), // handles month boundaries correctly. now.day - (now.weekday - 1)= 2 - 6 = -4  ← Invalid day!
    ); // Get the start of the week (Monday) at 00:00:00

    final endOfWeek = startOfWeek.add(
      const Duration(days: 7),
    ); // End of the week (next Monday) at 00:00:00
    for (final tx in transactions) {
      final date = DateTime.parse(tx.date); // Parse the date string to DateTime
      final amount =
          convertedAmounts[tx.id] ?? tx.amount; // convertedAmount if available
      if (tx.category.type == CategoryType.expense &&
          !date.isBefore(startOfWeek) &&
          date.isBefore(endOfWeek)) {
        int dayIndex = date.weekday - 1; // converting to 0-based index
        weeklyExpense[dayIndex] += amount;
      }
    }
    return weeklyExpense;
  }

  // Method to get monthly expenses
  List<double> get getMonthlyExpenses {
    List<double> monthlyExpense = List.filled(12, 0.0);
    final startOfYear = DateTime(
      DateTime.now().year,
      1,
      1,
    ); // Start of the year
    final endOfYear = DateTime(
      DateTime.now().year + 1,
      1,
      1,
    ); // End of the year
    final currentYear = DateTime.now().year;
    for (final tx in transactions) {
      final date = DateTime.parse(tx.date); // Parse the date string to DateTime
      final amount =
          convertedAmounts[tx.id] ?? tx.amount; // convertedAmount if available
      if (tx.category.type == CategoryType.expense &&
          date.year == currentYear) {
        int monthIndex = date.month - 1; // converting to 0-based index
        monthlyExpense[monthIndex] += amount;
      }
    }
    return monthlyExpense;
  }
}
