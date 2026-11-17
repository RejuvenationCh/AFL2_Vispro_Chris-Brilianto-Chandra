import 'package:flutter/material.dart';

import 'repository/gear_repository.dart';
import 'viewmodels/inventory_view_model.dart';
import 'views/inventory_page.dart';

void main() {
  final repository = GearRepository();
  final viewModel = InventoryViewModel(repository);

  runApp(
    MaterialApp(
      home: InventoryPage(viewModel),
    ),
  );
}
