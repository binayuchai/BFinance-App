enum CategoryType { income, expense, both } // Added enum for category type

// category "Both" is added to handle categories that can be used for both income and expense, like Other,Transfer,etc.
class Category {
  final int? id;
  final String name;
  final DateTime createdAt;
  final String icon;
  final CategoryType type;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  //Function to convert JSON  to Model(GET from API)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],

      name: json['name'],
      icon:
          json['icon'] ?? 'wallet', // Default to 'wallet' if iconKey is missing
      type: json['category_type'] == 'income'
          ? CategoryType.income
          : json['category_type'] == 'expense'
          ? CategoryType.expense
          : CategoryType.both,
    );
  }

  // Function to convert Model to JSON (POST to API)
  Map<String, dynamic> categoryToJson() {
    return {
      'name': name,
      'category_type': type == CategoryType.income
          ? 'income'
          : type == CategoryType.expense
          ? 'expense'
          : 'both',
      'icon': icon,
    };
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
