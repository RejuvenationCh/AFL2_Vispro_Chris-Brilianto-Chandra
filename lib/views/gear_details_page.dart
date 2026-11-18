import 'package:flutter/material.dart';

class GearDetailsPage extends StatelessWidget {
  const GearDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gear details'),
      ),
      body: const Center(
        child: Text('Gear information goes here'),
      ),
    );
  }
}