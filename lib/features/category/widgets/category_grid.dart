import 'package:bfinance/features/category/data/mappers/category_mapper.dart';
import 'package:flutter/material.dart';
import 'package:bfinance/features/category/data/models/category.dart';

class CategoryGrid extends StatelessWidget {
  final List<Category> categories; // List of categories to display
  final int? selectedCategoryId; // ID of the currently selected category
  final ValueChanged<int?>
  onCategorySelected; // Callback to notify parent of category selection
  final VoidCallback onAddCategory; // Callback to notify parent to add category

  const CategoryGrid({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onAddCategory,

    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      // Build a grid view to display categories
      shrinkWrap: true, // Let the grid take only the necessary space
      physics: NeverScrollableScrollPhysics(), // Disable scrolling for the grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // Number of columns in the grid
        childAspectRatio:
            1, // Aspect ratio for each grid item (reduced from 3 to prevent overflow)
        mainAxisSpacing: 8, // Spacing between rows
        crossAxisSpacing: 8, // Spacing between columns
      ),
      itemCount:
          categories.length + 1, // Number of items (categories + add button)
      itemBuilder: (context, index) {
        // If index is 0, show the "Add Category" button

        if (index == categories.length) {
          return GestureDetector(
            onTap: onAddCategory,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20, color: colorScheme.outline),
                  const SizedBox(height: 4),
                  Text(
                    "New",
                    style: TextStyle(fontSize: 10, color: colorScheme.outline),
                  ),
                ],
              ),
            ),
          );
        }
        final cat = categories[index];
        final isSelected = cat.id == selectedCategoryId;

        return GestureDetector(
          onTap: () => onCategorySelected(cat.id), //
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: .1)
                  : colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CategoryIconMapper.getIconData(cat.name),
                  size: 22,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
