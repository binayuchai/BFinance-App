import 'package:bfinance/features/category/data/mappers/category_mapper.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/features/category/data/models/category.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  String? _nameError;
  String? _selectedIconKey;
  final _nameController = TextEditingController();

  // all available icons for selection that matches the CategoryIconMapper
  static const List<({String key, String label})> _iconOptions = [
    (key: 'wallet', label: 'Wallet'),
    (key: 'food', label: 'Food'),
    (key: 'transport', label: 'Transport'),
    (key: 'health', label: 'Health'),
    (key: 'education', label: 'Education'),
    (key: 'shopping_cart', label: 'Shopping'),
    (key: 'restaurant', label: 'Restaurant'),
    (key: 'entertainment', label: 'Fun'),
    (key: 'salary', label: 'Salary'),
    (key: 'gift', label: 'Gift'),
    (key: 'groceries', label: 'Groceries'),
    (key: 'rent', label: 'Rent'),
    (key: 'pets', label: 'Pets'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    // Implement save logic here
    // Return true to indicate a new category was added
    Navigator.pop(context, true);
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = "Category name cannot be empty";
      });
      return;
    }
    //validate icon
    if (_selectedIconKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an icon for the category")),
      );
      return;
    }
    // If validation passes, pop with true to indicate a new category was added
    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch, // Generate a unique ID
      name: _nameController.text.trim(),
      icon: _selectedIconKey!,
    );
    Navigator.pop(context, newCategory);
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
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() {
                    _nameError = null; // Clear error when user starts typing
                  });
                }
              },
            ),

            const SizedBox(height: 20),
            // Add more fields as needed
            Text(
              "Choose an icon",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 10),

            // Implement the icon selection UI here, e.g., a grid of icons to choose from
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: _iconOptions.length,
              itemBuilder: (context, index) {
                final option =
                    _iconOptions[index]; // Get the current icon option
                final isSelected =
                    option.key ==
                    _selectedIconKey; // Check if this icon is currently selected
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedIconKey = option.key;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CategoryIconMapper.getIconData(option.key),
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Preview of the selected icon
            if (_selectedIconKey != null && _nameController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),

                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Icon(
                        CategoryIconMapper.getIconData(_selectedIconKey!),
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _nameController.text,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(), // Add a spacer to push the edit button to the right
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),

            // Save button or other actions can be added here
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Save Category"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
