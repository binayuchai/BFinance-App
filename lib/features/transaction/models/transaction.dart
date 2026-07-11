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
  final String currencyCode; // Store the currency code for this transaction
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
    required this.currencyCode,
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
      currencyCode:
          json['currency_code'] ?? 'USD', // Default to USD if not provided
      note: json['description'] ?? '',
      categoryId: json['category'], // Store category ID for API interactions
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
      'currency_code': currencyCode,
      'description': note ?? '',
      'category': categoryId,
      'transaction_type': isIncome ? 'credit' : 'debit',
    };
  }
}
