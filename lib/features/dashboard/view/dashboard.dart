import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:bfinance/features/dashboard/view/widgets/balance_card.dart';
import 'package:bfinance/widgets/transaction/transaction_list.dart';
import 'package:flutter/material.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BFinance Tracker')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          BalanceCard(),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),

          Expanded(child: TransactionList()),
        ],
      ),
    );
  }
}
