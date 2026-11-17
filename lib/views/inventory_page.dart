import 'package:flutter/material.dart';

import '../viewmodels/inventory_view_model.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage(this.viewModel, {super.key});

  final InventoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final items = viewModel.items;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gear Loan Log'),
          ),
          body: ListView(
            children: [
              if (items.isEmpty) const ListTile(title: Text('No gear yet')),

              for (final gear in items)
                ListTile(
                  title: Text(gear.name),
                  subtitle: Text(
                    gear.loan == null
                        ? 'Available'
                        : 'On loan to ${gear.loan!.borrower}',
                  ),
                  onTap: () {
                    if (gear.loan == null) {
                      showLendDialog(context, gear.id);
                    } else {
                      showReturnDialog(context, gear.id);
                    }
                  },
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddGearDialog(context),
            label: const Text('Add gear'),
          ),
        );
      },
    );
  }

  Future<void> showLendDialog(BuildContext context, int gearId) async {
    var borrower = '';
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Lend gear'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Borrower name'),
            onChanged: (value) {
              borrower = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (borrower.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, borrower);
                }
              },
              child: const Text('Choose due date'),
            ),
          ],
        );
      },
    );

    if (name == null || !context.mounted) return;
    final today = DateTime.now();
    final dueDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );

    if (dueDate == null || !context.mounted) return;
    viewModel.lendGear(gearId, name, dueDate);
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

  void showReturnDialog(BuildContext context, int gearId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Return gear?'),
          content: const Text('Mark this item as available again?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                viewModel.returnGear(gearId);
                Navigator.pop(dialogContext);
              },
              child: const Text('Mark returned'),
            ),
          ],
        );
      },
    );
  }
}
