import 'package:bfinance/features/dashboard/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bfinance/providers/transaction_provider.dart';
// class TransactionList extends  {
//   final List<Transaction> transactions;
//   const TransactionList({super.key, required this.transactions});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: transactions.length,
//       itemBuilder: (context, index) {
//         final tx = transactions[index];

//         return ListTile(
//           leading: tx.icon,
//           title: Text(tx.title, style: TextStyle(fontWeight: FontWeight.w500)),
//           subtitle: Text(
//             "USD ${tx.amount}",
//             style: TextStyle(color: tx.isIncome ? Colors.green : Colors.red),
//           ),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [Text(tx.date), Text(tx.time)],
//           ),
//         );
//       },
//     );
//   }
// }

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
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    if (transactionProvider.isLoading) {
      return Center(child: Text("Loading transactions..."));
    }

    final transactions = transactionProvider.transactions;
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];

        return ListTile(
          leading: tx.icon,
          title: Text(tx.title, style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            "USD ${tx.amount}",
            style: TextStyle(color: tx.isIncome ? Colors.green : Colors.red),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text(tx.date), Text(tx.time)],
          ),
        );
      },
    );
  }
}
