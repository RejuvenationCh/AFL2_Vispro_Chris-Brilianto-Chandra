import '../models/gear.dart';
import '../models/gear_loan.dart';

class GearRepository {
  final List<Gear> _items = [];
  int _nextId = 1;

  void add(String name) {
    final gear = Gear(_nextId, name);
    _items.add(gear);
    _nextId++;
  }

  List<Gear> list() {
    return List.of(_items);
  }

  // Return false if item is on a loan or is not existed into existence yet
  bool lend(int id, GearLoan loan) {
    for (var index = 0; index < _items.length; index++) {
      final gear = _items[index];

      if (gear.id == id) {
        if (gear.loan != null) {
          // False = Data found but is loaned
          return false;
        }
        _items[index] = Gear(
          gear.id,
          gear.name,
          loan: loan,
        );
        // True = Gear is loaned
        return true;
      }
    }
    // Item not found
    return false;
  }

  bool returnGear(int id) {
    for (var index = 0; index < _items.length; index++) {
      final gear = _items[index];
      if (gear.id == id) {
        if (gear.loan == null) {
          return false;
        }
        _items[index] = Gear(gear.id, gear.name);
        return true;
      }
    }
    return false;
  }
}
