import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryIncome extends StatefulWidget {
  const CategoryIncome({super.key});

  @override
  State<CategoryIncome> createState() => _CategoryIncomeState();
}

class _CategoryIncomeState extends State<CategoryIncome> {
  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();

    if (transactionProvider.isLoading) {
      return Center(child: Text("Loading transactions..."));
    }
    final List<Transaction> incomeTransactions = transactionProvider
        .transactions
        .where((tx) => tx.isIncome)
        .toList();
    if (incomeTransactions.isEmpty) {
      return Center(child: Text("No income transactions yet"));
    }

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
