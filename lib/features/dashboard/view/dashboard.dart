import 'package:bfinance/features/dashboard/view/widgets/balance_card.dart';
import 'package:flutter/material.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BFinance Tracker')),
      body: SingleChildScrollView(
        child: Column(children: const [BalanceCard()]),
      ),
    );
  }
}
