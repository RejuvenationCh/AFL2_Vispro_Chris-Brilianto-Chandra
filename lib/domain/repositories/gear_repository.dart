import '../models/gear.dart';
import '../models/gear_loan.dart';

abstract interface class GearRepository {
  Future<void> load();

  List<Gear> list();

  Future<void> add(String name);

  Future<bool> lend(int id, GearLoan loan);

  Future<bool> returnGear(int id);
}
