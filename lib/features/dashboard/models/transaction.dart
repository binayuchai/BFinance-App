import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum TransactionType { income, expense } // Added enum for transaction type

class Transaction {
  final int id;
  final String? category;
  final String title; // e.g., "Salary", "Groceries"
  final String date;
  final double amount;
  final Icon? icon;
  final TransactionType type;
  final String time;
  final String? paymentMethod;
  final String? note;

  Transaction({
    required this.id,
    required this.title,
    this.category,
    required this.date,
    required this.amount,
    required this.type,
    this.icon,
    required this.time,
    this.paymentMethod,
    this.note,
  });
  bool get isIncome =>
      type == TransactionType.income; // Helper getter to check if it's income

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: double.parse(json['amount']),
      type: json['transaction_type'] == 'Credit'
          ? TransactionType.income
          : TransactionType.expense,
      note: json['description'] ?? '',
      category: json['category'] ?? '',
      date: (json['created_at']),
      time: json['time'] ?? '',
    );
  }

  // Function to convert Model to JSON (POST to API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'transaction_type': type == TransactionType.income ? 'Credit' : 'Debit',
      'description': note ?? '',
      'category': category ?? '',
      'created_at': date,
    
    };
  }
}

// Function to convert JSON  to Model(GET from API)

final List<Transaction> transactions = [
  Transaction(
    id: 1,
    title: "Salary",
    date: "2025-08-01",
    amount: 3000.00,
    type: TransactionType.income,
    icon: const Icon(Icons.wallet, color: Colors.blue),
    time: "10:00 AM",
  ),
  Transaction(
    id: 2,
    title: "Groceries",
    date: "2025-08-05",
    amount: 150.75,
    type: TransactionType.expense,
    icon: const Icon(Icons.medical_services, color: Colors.teal),
    time: "2:30 PM",
  ),
  Transaction(
    id: 3,
    title: "Electricity Bill",
    date: "2025-08-10",
    amount: 80.50,
    type: TransactionType.expense,
    icon: const Icon(Icons.electric_bolt, color: Colors.blue),
    time: "9:00 AM",
  ),
  Transaction(
    id: 4,
    title: "Freelance Project",
    date: "2025-08-15",
    amount: 500.00,
    type: TransactionType.income,
    icon: const Icon(Icons.attach_money, color: Colors.green),
    time: "1:00 PM",
  ),
];
