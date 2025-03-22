import 'package:drums/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarWidget extends StatelessWidget {
  const BarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BarModel>(
      builder: (BuildContext context, BarModel bar, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              bar.selectedDrums.map((Drums drum) => Text(drum.name)).toList(),
        );
      },
    );
  }
}
