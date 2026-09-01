import 'package:bfinance/features/dashboard/view/widgets/transaction.dart';
import 'package:bfinance/providers/currency_provider.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:bfinance/widgets/transaction/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentTransactions extends StatelessWidget {
  final int limit;

  const RecentTransactions({super.key, this.limit = 5});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    final colorScheme = Theme.of(context).colorScheme;
    final recent = provider.transactions.take(limit).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,

                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the full transaction list page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionPage(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "No transactions yet.",
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // this list doesn't scroll on its own; the parent screen does
            itemCount: recent.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,

              color: colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final transaction = recent[index];
              return TransactionTile(
                tx: transaction,
                convertedAmount: provider.getConvertedAmount(transaction.id!),
                currencySymbol: currencyProvider.currencyCode,
              );
            },
          ),
      ],
    );
  }
}
