import 'package:flutter/material.dart';

import '../viewmodels/inventory_view_model.dart';
import '../models/gear.dart';
import 'gear_details_page.dart';

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
                  subtitle: Text(gearStatus(gear)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const GearDetailsPage();
                        },
                      ),
                    );
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

  String gearStatus(Gear gear) {
    final loan = gear.loan;
    if (loan == null) {
      return 'Available';
    } else {
      return 'On loan to ${loan.borrower}';
    }
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
    try {
      viewModel.lendGear(gearId, name, dueDate);
    } catch (_) {
      showSaveError(context);
    }
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
                try {
                  if (viewModel.addGear(name)) {
                    Navigator.pop(dialogContext);
                  }
                } catch (_) {
                  showSaveError(context);
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
                try {
                  viewModel.returnGear(gearId);
                  Navigator.pop(dialogContext);
                } catch (_) {
                  showSaveError(context);
                }
              },
              child: const Text('Mark returned'),
            ),
          ],
        );
      },
    );
  }

  void showSaveError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not save your change. Try again.'),
      ),
    );
  }
}
