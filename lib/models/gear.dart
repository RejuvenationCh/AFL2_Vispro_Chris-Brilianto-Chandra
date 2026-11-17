import 'gear_loan.dart';

class Gear {
  const Gear(
    this.id,
    this.name, {
    this.loan,
  });

  final int id;
  final String name;
  final GearLoan? loan;
}
