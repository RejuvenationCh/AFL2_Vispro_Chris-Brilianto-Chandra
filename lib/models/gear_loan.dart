class GearLoan {
  const GearLoan(
    this.borrower,
    this.dueDate,
  );

  final String borrower;
  final DateTime dueDate;

  Map<String, dynamic> toJson() {
    return {
      'borrower': borrower,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  static GearLoan fromJson(Map<String, dynamic> json) {
    return GearLoan(
      json['borrower'] as String,
      DateTime.parse(json['dueDate'] as String),
    );
  }
}
