import 'package:flutter/material.dart';

import '../models/gear.dart';
import '../viewmodels/inventory_view_model.dart';

class GearDetailsPage extends StatelessWidget {
  const GearDetailsPage(
    this.gear,
    this.viewModel, {
    super.key,
  });

  final Gear gear;
  final InventoryViewModel viewModel;

  Gear get currentGear {
    return viewModel.items.firstWhere(
      (item) => item.id == gear.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gear.name),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gearStatus()),
                const SizedBox(height: 24),
                if (currentGear.loan == null)
                  FilledButton(
                    onPressed: () {
                      showLendDialog(context, gear.id);
                    },
                    child: const Text('Lend gear'),
                  ),
                if (currentGear.loan != null)
                  FilledButton(
                    onPressed: () {
                      showReturnDialog(context, gear.id);
                    },
                    child: const Text('Mark returned'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String gearStatus() {
    final loan = currentGear.loan;

    if (loan == null) {
      return 'Available';
    } else {
      return 'On loan to ${loan.borrower}\n'
          'Due at : ${loan.dueDate.day}/${loan.dueDate.month}/${loan.dueDate.year}';
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
