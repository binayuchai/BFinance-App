import 'package:bfinance/features/category/widgets/expense.dart';
import 'package:bfinance/features/category/widgets/income.dart';
import 'package:bfinance/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Category extends StatelessWidget {
  const Category({super.key});

  Future<bool> _addCategory(BuildContext context, String name) async {
    // Implement the logic to add category to the database
    print("Adding category: $name");
    try {
      final response = await context
          .read<CategoryProvider>()
          .addCategoryProvider(name);
      return response;
    } catch (e) {
      print("Error adding category: $e");
      return false;
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: categoryController,
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
              if (formKey.currentState!.validate()) {
                _addCategory(context, categoryController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Category added successfully")),
                );
              }
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
