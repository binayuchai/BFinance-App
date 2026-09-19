import 'package:bfinance/features/dashboard/view/widgets/balance_card.dart';
import 'package:bfinance/features/dashboard/view/widgets/recent_transactions.dart';
import 'package:bfinance/providers/currency_provider.dart';
import 'package:bfinance/providers/transaction_provider.dart';
import 'package:bfinance/widgets/transaction/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currencyProvider = context.read<CurrencyProvider>();
      context.read<TransactionProvider>().ensureLoaded(
        currencyProvider: currencyProvider,
      );
    });
  }

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