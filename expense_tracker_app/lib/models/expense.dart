class Expense {
  final String? id;
  final String userId;
  final double amount;
  final String category;
  final String date;

  Expense({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      amount: double.parse(json['amount'].toString()),
      category: json['category'].toString(),
      date: json['date'].toString(),
    );
  }
}
