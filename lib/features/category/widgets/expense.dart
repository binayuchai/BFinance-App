import 'package:bfinance/core/utils/datetime_formatter.dart';
import 'package:bfinance/features/transaction/models/transaction.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/core/utils/amount_formatter.dart';

class CategoryExpenses extends StatefulWidget {
  const CategoryExpenses({super.key});

  @override
  State<CategoryExpenses> createState() => _CategoryExpensesState();
}

class _CategoryExpensesState extends State<CategoryExpenses> {
  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();

    if (transactionProvider.isLoading) {
      return Center(child: Text("Loading transactions..."));
    }
    final List<Transaction> expenseTransactions = transactionProvider
        .transactions
        .where((tx) => !tx.isIncome)
        .toList();
    if (expenseTransactions.isEmpty) {
      return Center(child: Text("No expense transactions yet"));
    }
    return ListView.builder(
      itemCount: expenseTransactions.length,

      itemBuilder: (context, index) {
        final tx = expenseTransactions[index];
        return ListTile(
          leading: tx.icon,
          title: Text(tx.title, style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            AmountFormatter.formatAmount(tx.amount),
            style: TextStyle(color: Colors.red),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(DateTimeFormatter.formatDate(tx.date)),
              Text(DateTimeFormatter.formatTime(tx.time)),
            ],
          ),
        );
      },
    );
  }
}
