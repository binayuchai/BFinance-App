import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:flutter/material.dart';

class TransactionSummary {
  final double totalIncome;
  final double totalExpenses;

  // Constructor to access the fields data
  TransactionSummary({required this.totalIncome, required this.totalExpenses});

  double get netBalance => totalIncome - totalExpenses;

  // factory method to create TransactionSummary from a list of transactions
  factory TransactionSummary.fromTransactions(List<Transaction> transactions) {
    double income = 0.0;
    double expenses = 0.0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else {
        expenses += tx.amount;
      }
    }

    return TransactionSummary(totalIncome: income, totalExpenses: expenses);
  }
}
