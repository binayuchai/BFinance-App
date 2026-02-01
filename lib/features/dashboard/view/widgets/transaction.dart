import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:bfinance/widgets/transaction/transaction_list.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction List')),
      body: TransactionList(),
    );
  }
}
