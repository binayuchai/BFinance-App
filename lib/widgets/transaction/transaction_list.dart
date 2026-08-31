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
      //load from cache if available, otherwise fetch from API
      final transactionProvider = context.read<TransactionProvider>();
      if (transactionProvider.transactions.isEmpty) {
        final currencyProvider = context.read<CurrencyProvider>();
        transactionProvider.ensureLoaded(currencyProvider: currencyProvider);
      }

      // // Fetch transactions only if they haven't been loaded yet from cache
      // final currencyProvider = context.read<CurrencyProvider>();
      // transactionProvider.ensureLoaded(currencyProvider: currencyProvider);
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
    return Column(
      children: [
        if (transactionProvider.ratesAreStale)
          Container(
            width: double.infinity,
            color: Colors.orange.shade100,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: const Text(
              "Exchange rates may be outdated (offline)",
              style: TextStyle(fontSize: 12),
            ),
          ),
        Expanded(
          child: ListView.builder(
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
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text(
                          "Are you sure you want to delete this transaction?",
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("CANCEL"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text("DELETE"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  final provider = context.read<TransactionProvider>();
                  final currencyProvider = context.read<CurrencyProvider>();

                  final removedIndex = provider.transactions.indexOf(tx);
                  provider.removeTransactionLocally(tx.id!); // remove first

                  final success = await provider.deleteTransactionProvider(
                    tx.id!,
                  );
                  if (!context.mounted) return;
                  if (!success && context.mounted) {
                    provider.restoreTransactionLocally(
                      removedIndex,
                      tx,
                      currencyProvider,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
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
                    style: TextStyle(
                      color: tx.isIncome ? Colors.green : Colors.red,
                    ),
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
          ),
        ),
      ],
    );
  }
}
