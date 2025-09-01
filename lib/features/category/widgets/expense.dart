import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:flutter/material.dart';

class CategoryExpenses extends StatelessWidget {
  const CategoryExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Transaction> expenseTransactions = transactions
        .where((tx) => !tx.isIncome)
        .toList();
    return ListView.builder(
      itemCount: expenseTransactions.length,

      itemBuilder: (context, index) {
        final tx = expenseTransactions[index];
        return ListTile(
          leading: tx.icon,
          title: Text(tx.title, style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            "USD ${tx.amount}",
            style: TextStyle(color: Colors.red),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text(tx.date), Text(tx.time)],
          ),
        );
      },
    );
  }
}
