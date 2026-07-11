import 'package:bfinance/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/currency_provider.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final summary = provider.summary;
    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4.0,
      color: Colors.blueGrey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Summary",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${currencyProvider.currencyCode} ${summary.netBalance.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
                Icon(Icons.wallet, color: Colors.blue, size: 32),
              ],
            ),
            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green),
                    Column(
                      children: [
                        Text("Income"),
                        Text(
                          "${currencyProvider.currencyCode} ${summary.totalIncome.toStringAsFixed(2)}",
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.red),
                    Column(
                      children: [
                        Text("Expenses"),
                        Text(
                          "${currencyProvider.currencyCode} ${summary.totalExpenses.toStringAsFixed(2)}",
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
