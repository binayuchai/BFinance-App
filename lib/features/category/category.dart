import 'package:bfinance/features/category/widgets/expense.dart';
import 'package:bfinance/features/category/widgets/income.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Category extends StatelessWidget {
  const Category({super.key});

  void _showAddCategoryDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: "Category Name",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter category name";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
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
              onPressed: () {
                // Add category logic here
                _showAddCategoryDialog(context);
              },
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
