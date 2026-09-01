import 'package:bfinance/core/utils/amount_formatter.dart';
import 'package:bfinance/core/utils/datetime_formatter.dart';
import 'package:bfinance/features/transaction/models/transaction.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final Transaction tx;
  final double convertedAmount;
  final String currencySymbol;
  final VoidCallback? onTap;
  const TransactionTile({
    super.key,
    required this.tx,
    required this.convertedAmount,
    required this.currencySymbol,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: tx.icon,
      title: Text(
        tx.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        AmountFormatter.formatAmountSync(tx.amount, tx.currencyCode),
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
      onTap: onTap,
    );
  }
}
