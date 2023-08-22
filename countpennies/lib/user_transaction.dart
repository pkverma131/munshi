class UserTransaction {
  String id;
  String title;
  double amount;

  UserTransaction({required this.id, required this.title, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
    };
  }

  factory UserTransaction.fromMap(Map<String, dynamic> map) {
    return UserTransaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
    );
  }

  void updateTransaction({required String newTitle, required double newAmount}) {
    title = newTitle;
    amount = newAmount;
  }
}
