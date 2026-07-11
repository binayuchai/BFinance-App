import 'package:bfinance/core/utils/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:bfinance/widgets/forms/edit_transaction_form.dart';
import 'package:bfinance/core/utils/datetime_formatter.dart';
import 'package:bfinance/providers/currency_provider.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  void initState() {
    super.initState();
    // Load transactions or perform any initialization here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currencyProvider = context.read<CurrencyProvider>();
      context.read<TransactionProvider>().fetchTransactions(
        currencyProvider: currencyProvider,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    if (transactionProvider.isLoading) {
      return Center(child: Text("Loading transactions..."));
    }

    final transactions = transactionProvider.transactions;
    if (transactions.isEmpty) {
      return Center(child: Text("No transactions found."));
    }
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];

        return Dismissible(
          key: Key(tx.id.toString()),
          direction: DismissDirection.endToStart, // Swipe left to delete
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) async {
            final success = await context
                .read<TransactionProvider>()
                .deleteTransactionProvider(tx.id!);
            if (!context.mounted) return;
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Failed to delete the transaction. Please try again.",
                  ),
                ),
              );
            }
          },
          child: ListTile(
            onTap: () async {
              // Navigate to details or edit screen
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return EditTransactionForm(transactions: tx);
                },
              );
            },
            leading: tx.icon,
            title: Text(
              tx.title,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              AmountFormatter.formatAmountSync(
                transactionProvider.getConvertedAmount(tx.id!),
                currencyProvider.currencyCode,
              ),
              style: TextStyle(color: tx.isIncome ? Colors.green : Colors.red),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(DateTimeFormatter.formatDate(tx.date)),
                Text(DateTimeFormatter.formatTime(tx.time)),
              ],
            ),
          ),
        );
      },
    );
  }
}
