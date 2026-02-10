import 'package:flutter/material.dart';

class CategoryColorHelper {
  // List of predefined colors for categories(STATIC VARIABLE TO AVOID MEMORY RE-CREATION)
  static const List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.cyan,
    Colors.amber,
    Colors.indigo,
    Colors.pink,
    Colors.lime,
    Colors.brown,
  ];

  // Method to get color based on category ID like hash function(static to avoid re-creation)
  static Color getColorForCategory(int categoryId) {
    return _colors[categoryId % _colors.length];
  }
}
