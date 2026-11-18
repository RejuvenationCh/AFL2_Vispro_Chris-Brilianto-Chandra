import '../../models/gear.dart';
import '../../models/gear_loan.dart';

abstract interface class GearRepository {
  void load();

  List<Gear> list();

  void add(String name);

  bool lend(int id, GearLoan loan);

  bool returnGear(int id);
}
