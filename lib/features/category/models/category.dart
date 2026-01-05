import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final DateTime createdAt;
  final Icon? icon;

  Category({this.id, required this.name, this.icon, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  //Function to convert JSON  to Model(GET from API)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      icon: json['icon']
          ? Icon(IconData(json['icon'], fontFamily: 'MaterialIcons'))
          : Icon(Icons.wallet),
    );
  }
  // Function to convert Model to JSON (POST to API)
  Map<String, dynamic> categoryToJson() {
    return {'name': name};
  }
}

// final List<Category> categories = [
//   Category(id: "1", name: "Salary", type: "income"),
//   Category(id: "2", name: "Freelance", type: "income"),
//   Category(id: "3", name: "Investments", type: "income"),
//   Category(id: "4", name: "Groceries", type: "expense"),
//   Category(id: "5", name: "Rent", type: "expense"),
//   Category(id: "6", name: "Utilities", type: "expense"),
//   Category(id: "7", name: "Entertainment", type: "expense"),
// ];
