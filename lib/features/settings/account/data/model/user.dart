class UserModel {
  final int id;
  final String email;
  final String name;
  final String defaultCurrency;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.defaultCurrency,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      defaultCurrency: json['default_currency'] ?? 'USD',
    );
  }
}
