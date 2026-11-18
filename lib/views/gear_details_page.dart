import 'package:flutter/material.dart';

import '../models/gear.dart';

class GearDetailsPage extends StatelessWidget {
  const GearDetailsPage(
    this.gear, {
    super.key,
  });

  final Gear gear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gear.name),
      ),
      body: Center(
        child: Text(gear.name),
      ),
    );
  }
}
