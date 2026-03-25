import 'package:flutter/material.dart';

class CategoryIconMapper {
  // single source of truth — add new icons here only
  static const Map<String, IconData> _icons = {
    'wallet': Icons.account_balance_wallet,
    'food': Icons.fastfood,
    'transport': Icons.directions_bus,
    'health': Icons.health_and_safety,
    'education': Icons.school,
    'shopping_cart': Icons.shopping_cart,
    'restaurant': Icons.restaurant,
    'entertainment': Icons.movie,
    'salary': Icons.attach_money,
    'gift': Icons.card_giftcard,
    'groceries': Icons.shopping_cart,
    'rent': Icons.home_outlined,
    'pets': Icons.pets,
  };

  // returns IconData — use when something expects IconData
  // e.g. ListTile(leading: Icon(CategoryIconMapper.getIconData(key)))
  static IconData getIconData(String? iconName) {
    return _icons[iconName] ?? Icons.wallet;
  }

  // returns Icon widget — use when something expects a Widget
  // e.g. CategoryIconMapper.getIcon(key)
  static Icon getIcon(String? iconName, {Color? color, double size = 24}) {
    return Icon(getIconData(iconName), color: color, size: size);
  }
}
