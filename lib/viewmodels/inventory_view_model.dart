import '../models/gear.dart';
import '../domain/repositories/gear_repository.dart';
import '../models/gear_loan.dart';

import 'package:flutter/foundation.dart';

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this._repository);

  final GearRepository _repository;

  List<Gear> get items {
    return _repository.list();
  }

  bool addGear(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      return false;
    }

    _repository.add(cleanName);
    notifyListeners();
    return true;
  }

  void lendGear(int id, String borrower, DateTime dueDate) {
    final name = borrower.trim();
    if (name.isEmpty) return;

    final loan = GearLoan(name, dueDate);
    final saved = _repository.lend(id, loan);

    if (saved) {
      notifyListeners();
    }
  }

  void returnGear(int id) {
    final saved = _repository.returnGear(id);

    if (saved) {
      notifyListeners();
    }
  }
}
