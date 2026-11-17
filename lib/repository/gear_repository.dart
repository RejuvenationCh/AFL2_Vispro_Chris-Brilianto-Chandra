import '../models/gear.dart';

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
}
