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
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      if (!mounted) return;

      final currencyProvider = context.read<CurrencyProvider>();
      final transactionProvider = context.read<TransactionProvider>();
      print('Transaction during dashboard, ${transactionProvider.transactions}');

      if(!transactionProvider.isLoaded && transactionProvider.transactions.isEmpty){
        //first time ever - no cache
        await transactionProvider.ensureLoaded(
          currencyProvider: currencyProvider,
        );

      }
      else{
        // Already loaded (likely from main.dart's cache-only load at startup
        await transactionProvider.convertAllAmount(currencyProvider);
      }


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