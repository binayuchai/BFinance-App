import 'package:flutter/material.dart';

class CategoryIconMapper {
  static Icon getIcon(String? iconName) {
    // we used static so that we can call it without creating an instance,not to store state, just a utility convert string to icon
    switch (iconName) {
      case 'wallet':
        return Icon(Icons.account_balance_wallet);
      case 'food':
        return Icon(Icons.fastfood);
      case 'transport':
        return Icon(Icons.directions_bus);
      case 'health':
        return Icon(Icons.health_and_safety);
      case 'education':
        return Icon(Icons.school);
      case 'shopping_cart':
        return Icon(Icons.shopping_cart);
      case 'restaurant':
        return Icon(Icons.restaurant);
      case 'entertainment':
        return Icon(Icons.movie);
      case 'salary':
        return Icon(Icons.attach_money);
      case 'gift':
        return Icon(Icons.card_giftcard);
      default:
        return Icon(Icons.wallet);
    }
  }
}
