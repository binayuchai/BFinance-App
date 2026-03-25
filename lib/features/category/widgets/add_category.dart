import 'package:bfinance/features/category/data/mappers/category_mapper.dart';
import 'package:flutter/material.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  String? _nameError;
  String? _selectedIconKey;
  final _nameController = TextEditingController();

  void _onSave() {
    // Implement save logic here
    // Return true to indicate a new category was added
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("New Category"),
        actions: [
          TextButton(
            onPressed: _onSave,

            // Implement save logic here
            // Return true to indicate a new category was added
            child: Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add form fields for category name, type, etc.
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Category Name",
                errorText: _nameError,
                hintText: "e.g Food",
                prefixIcon: _selectedIconKey != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          CategoryIconMapper.getIconData(_selectedIconKey!),
                          color: colorScheme
                              .primary, // You can customize the icon color
                        ), // Replace with actual icon based on _selectedIconKey
                      )
                    : const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
