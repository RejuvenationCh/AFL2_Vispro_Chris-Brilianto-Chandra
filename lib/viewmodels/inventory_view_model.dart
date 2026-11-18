import '../models/gear.dart';
import '../domain/repositories/gear_repository.dart';
import '../models/gear_loan.dart';

import 'package:flutter/foundation.dart';

import 'inventory_state.dart';

class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this._repository);

  InventoryState _state = const InventoryLoading();
  InventoryState get state => _state;

  final GearRepository _repository;

  List<Gear> get items {
    final currentState = _state;
    if (currentState is InventoryLoaded) {
      return currentState.items;
    }
    return const [];
  }

  void load() {
    _setState(const InventoryLoading());
    try {
      _repository.load();
      _refreshItems();
    } catch (_) {
      _setState(const InventoryError('Could not load your gear. Try again.'));
    }
  }

  void _refreshItems() {
    _setState(InventoryLoaded(_repository.list()));
  }

  void _setState(InventoryState nextState) {
    if (_state == nextState) return;

    _state = nextState;
    notifyListeners();
  }

  bool addGear(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      return false;
    }

    _repository.add(cleanName);
    _refreshItems();
    return true;
  }

  void lendGear(int id, String borrower, DateTime dueDate) {
    final name = borrower.trim();
    if (name.isEmpty) return;

    final loan = GearLoan(name, dueDate);
    final saved = _repository.lend(id, loan);

    if (saved) {
      _refreshItems();
    }
  }

  void returnGear(int id) {
    final saved = _repository.returnGear(id);

    if (saved) {
      _refreshItems();
    }
  }
}
