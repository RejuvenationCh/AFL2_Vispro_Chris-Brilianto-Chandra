import 'package:flutter/material.dart';

import '../viewmodels/inventory_view_model.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage(this.viewModel, {super.key});

  final InventoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final items = viewModel.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Gear Loan Log')),
      body: items.isEmpty
          ? const Center(child: Text('No gear yet'))
          : ListView(
              children: [
                for (final gear in items) ListTile(title: Text(gear.name)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddGearDialog(context),
        label: const Text('Add gear'),
      ),
    );
  }

  void showAddGearDialog(BuildContext context) {
    var name = '';
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add gear'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Gear name'),
            onChanged: (value) {
              name = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (viewModel.addGear(name)) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
