import '../../domain/repositories/gear_repository.dart';
import '../../models/gear.dart';
import '../../models/gear_loan.dart';

class MemoryGearRepository implements GearRepository {
  final List<Gear> _items = [];
  int _nextId = 1;

  @override
  void load() {}

  @override
  List<Gear> list() {
    return List.of(_items);
  }

  @override
  void add(String name) {
    _items.add(Gear(_nextId, name));
    _nextId++;
  }

  @override
  bool lend(int id, GearLoan loan) {
    for (var index = 0; index < _items.length; index++) {
      final gear = _items[index];
      if (gear.id == id) {
        if (gear.loan != null) return false;

        _items[index] = Gear(gear.id, gear.name, loan: loan);
        return true;
      }
    }
    return false;
  }

  @override
  bool returnGear(int id) {
    for (var index = 0; index < _items.length; index++) {
      final gear = _items[index];
      if (gear.id == id) {
        if (gear.loan == null) return false;

        _items[index] = Gear(gear.id, gear.name);
        return true;
      }
    }
    return false;
  }
}
