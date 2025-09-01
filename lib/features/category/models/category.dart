class Category {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

final List<Category> categories = [
  Category(id: "1", name: "Salary", type: "income"),
  Category(id: "2", name: "Freelance", type: "income"),
  Category(id: "3", name: "Investments", type: "income"),
  Category(id: "4", name: "Groceries", type: "expense"),
  Category(id: "5", name: "Rent", type: "expense"),
  Category(id: "6", name: "Utilities", type: "expense"),
  Category(id: "7", name: "Entertainment", type: "expense"),
];
