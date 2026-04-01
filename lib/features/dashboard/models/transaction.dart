import 'package:flutter/material.dart';
import 'package:bfinance/features/category/data/models/category.dart';

class Transaction {
  final int? id;
  final int categoryId; // Store category ID for API interactions
  // final String? categoryName; // Added category name field
  final String title; // e.g., "Salary", "Groceries"
  final String date;
  final double amount;
  final String time;
  final String? paymentMethod;
  final String? note;
  final Icon? icon;
  final Category category; // Store the category object for type checking

  Transaction({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.time,
    // this.categoryName, // Initialize category name
    this.paymentMethod,
    this.note,
    this.icon,
    required this.categoryId,
  });

  bool get isIncome =>
      category.type ==
      CategoryType.income; // Helper getter to check if it's income

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final typStr = (json['transaction_type'] ?? '').toString().toLowerCase();
    print("Parsing transaction: $json, determined type: $typStr");

    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: double.parse(json['amount']),

      note: json['description'] ?? '',
      categoryId: json['category'],
      category: Category.fromJson(
        json['category_detail'],
      ), // Parse the category object

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
      'description': note ?? '',
      'category': categoryId,
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
