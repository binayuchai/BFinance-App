enum CategoryType { income, expense } // Added enum for category type

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
          json['iconKey'] ??
          'wallet', // Default to 'wallet' if iconKey is missing
      type: json['type'] == 'income'
          ? CategoryType.income
          : CategoryType.expense,
    );
  }

  // Function to convert Model to JSON (POST to API)
  Map<String, dynamic> categoryToJson() {
    return {
      'name': name,
      'transaction_type': type == CategoryType.income ? 'credit' : 'debit',
      'iconKey': icon,
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
