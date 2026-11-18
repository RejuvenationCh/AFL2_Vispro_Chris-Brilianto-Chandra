import '../models/gear_loan.dart';

class Gear {
  const Gear(
    this.id,
    this.name, {
    this.loan,
  });

  final int id;
  final String name;
  final GearLoan? loan;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'loan': loan?.toJson(),
    };
  }

  static Gear fromJson(Map<String, dynamic> json) {
    GearLoan? savedLoan;
    if (json['loan'] != null) {
      savedLoan = GearLoan.fromJson(
        json['loan'] as Map<String, dynamic>,
      );
    }
    return Gear(
      json['id'] as int,
      json['name'] as String,
      loan: savedLoan,
    );
  }
}
