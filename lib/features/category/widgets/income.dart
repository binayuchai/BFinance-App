import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:flutter/material.dart';

class CategoryIncome extends StatelessWidget {
  const CategoryIncome({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Transaction> incomeTransactions = transactions
        .where((tx) => tx.isIncome)
        .toList();
    return ListView.builder(
      itemCount: incomeTransactions.length,
      itemBuilder: (context, index) {
        final tx = incomeTransactions[index];
        return ListTile(
          leading: tx.icon,
          title: Text(tx.title, style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            "USD ${tx.amount}",
            style: TextStyle(color: Colors.green),
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
