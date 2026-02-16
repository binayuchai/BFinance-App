import 'package:bfinance/features/category/category.dart';
import 'package:flutter/material.dart';

enum TransactionType { income, expense } // Added enum for transaction type

class Transaction {
  final int? id;
  final int category;
  final String? categoryName; // Added category name field
  final String title; // e.g., "Salary", "Groceries"
  final String date;
  final double amount;
  final TransactionType type;
  final String time;
  final String? paymentMethod;
  final String? note;
  final Icon? icon;

  Transaction({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
    required this.time,
    this.categoryName, // Initialize category name
    this.paymentMethod,
    this.note,
    this.icon,
  });
  bool get isIncome =>
      type == TransactionType.income; // Helper getter to check if it's income

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final typStr = (json['transaction_type'] ?? '').toString().toLowerCase();
    print("Parsing transaction: $json, determined type: $typStr");

    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: double.parse(json['amount']),
      type: typStr == 'credit'
          ? TransactionType.income
          : TransactionType.expense,
      note: json['description'] ?? '',
      category: json['category'],
      categoryName: json['category_detail'] ?? '',

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
      'transaction_type': type == TransactionType.income ? 'credit' : 'debit',
      'description': note ?? '',
      'category': category,
      'created_at': date,
    };
  }
}

// Function to convert JSON  to Model(GET from API)

// final List<Transaction> transactions = [
//   Transaction(
//     id: 1,
//     title: "Salary",
//     date: "2025-08-01",
//     amount: 3000.00,
//     type: TransactionType.income,
//     icon: const Icon(Icons.wallet, color: Colors.blue),
//     time: "10:00 AM",
//     category: 1,
//   ),
//   Transaction(
//     id: 2,
//     title: "Groceries",
//     date: "2025-08-05",
//     amount: 150.75,
//     type: TransactionType.expense,
//     icon: const Icon(Icons.medical_services, color: Colors.teal),
//     time: "2:30 PM",
//     category: 4,
//   ),
//   Transaction(
//     id: 3,
//     title: "Electricity Bill",
//     date: "2025-08-10",
//     amount: 80.50,
//     type: TransactionType.expense,
//     icon: const Icon(Icons.electric_bolt, color: Colors.blue),
//     time: "9:00 AM",
//     category: 6,
//   ),
//   Transaction(
//     id: 4,
//     title: "Freelance Project",
//     date: "2025-08-15",
//     amount: 500.00,
//     type: TransactionType.income,
//     icon: const Icon(Icons.attach_money, color: Colors.green),
//     time: "1:00 PM",
//     category: 2,
//   ),
// ];
