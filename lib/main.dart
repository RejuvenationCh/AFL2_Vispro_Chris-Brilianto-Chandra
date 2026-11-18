import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'data/repositories/json_gear_repository.dart';
import 'viewmodels/inventory_view_model.dart';
import 'views/inventory_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final folder = await getApplicationSupportDirectory();
    final file = File('${folder.path}/gear.json');
    final repository = JsonGearRepository(file);
    repository.load();
    final viewModel = InventoryViewModel(repository);

    runApp(
      MaterialApp(
        home: InventoryPage(viewModel),
      ),
    );
  } catch (_) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Could not open your saved gear.'),
          ),
        ),
      ),
    );
  }
}
