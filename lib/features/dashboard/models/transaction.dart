import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class Transaction {
  final String title;
  final String date;
  final double amount;
  final bool isIncome;
  final Icon icon;
  final String time;
  final String? paymentMethod;

  Transaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.time,
    this.paymentMethod,
  });
}

final List<Transaction> transactions = [
  Transaction(
    title: "Salary",
    date: "2025-08-01",
    amount: 3000.00,
    isIncome: true,
    icon: const Icon(Icons.wallet, color: Colors.blue),
    time: "10:00 AM",
  ),
  Transaction(
    title: "Groceries",
    date: "2025-08-05",
    amount: 150.75,
    isIncome: false,
    icon: const Icon(Icons.medical_services, color: Colors.teal),
    time: "2:30 PM",
  ),
  Transaction(
    title: "Electricity Bill",
    date: "2025-08-10",
    amount: 80.50,
    isIncome: false,
    icon: const Icon(Icons.electric_bolt, color: Colors.blue),
    time: "9:00 AM",
  ),
  Transaction(
    title: "Freelance Project",
    date: "2025-08-15",
    amount: 500.00,
    isIncome: true,
    icon: const Icon(Icons.attach_money, color: Colors.green),
    time: "1:00 PM",
  ),
];
