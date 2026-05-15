import 'package:bfinance/features/category/widgets/expense.dart';
import 'package:bfinance/features/category/widgets/income.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/providers/category_provider.dart';
import 'package:bfinance/features/category/widgets/add_category.dart'; // import your screen
import 'package:provider/provider.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  // Future<bool> _addCategory(BuildContext context, String name) async {
  //   // Implement the logic to add category to the database

  Future<void> _showAddCategoryDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCategory()),
    );
    if (result == true) {
      if (!mounted) return;
      context.read<CategoryProvider>().fetchCategories(); // refresh after add
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category added successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Category"),

          actions: [
            IconButton(
              onPressed: _showAddCategoryDialog,
              icon: const Icon(Icons.add),
              tooltip: 'Add Category',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wallet, color: Colors.green),
                    Text("Income"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wallet, color: Colors.red),
                    Text("Expenses"),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [CategoryIncome(), CategoryExpenses()],
        ),
      ),
    );
  }
}
