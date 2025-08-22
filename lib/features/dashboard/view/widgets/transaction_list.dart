import 'package:flutter/material.dart';

class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final transactions = [
    {"name": "Groceries", "data": "USD 150", "icon": Icon(Icons.shopping_cart)},
    {"name": "Salary", "data": "USD 3000", "icon": Icon(Icons.attach_money)},
    {"name": "Utilities", "data": "USD 200", "icon": Icon(Icons.lightbulb_outline)},
    {"name": "Transport", "data": "USD 100", "icon": Icon(Icons.directions_bus)},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction List')),
      body: ListView.builder(
        itemCount:transactions.length,
        itemBuilder:(context, index) {
          final tx = transactions[index];

         return ListTile(
            title: Text("name"),
            subtitle: Text("${tx['data']}"),
            trailing: transactions["icon"],
          
        
      );
    );
    }
}

  

