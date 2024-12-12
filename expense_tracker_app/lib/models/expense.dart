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

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }
}
