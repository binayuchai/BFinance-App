import 'package:bfinance/features/dashboard/view/widgets/balance_card.dart';
import 'package:bfinance/features/dashboard/view/widgets/recent_transactions.dart';
import 'package:bfinance/providers/currency_provider.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:bfinance/widgets/transaction/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          const SizedBox(height: 12),
          RecentTransactions(limit: 5),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
