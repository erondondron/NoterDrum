import 'package:drums/models/bar.dart';
import 'package:drums/models/drum_set.dart';
import 'package:drums/shared/fix_height_row.dart';
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
          children: [
            FixHeightRow(children: [Text("Bar:")]),
            ...bar.selectedDrums.map(
              (Drums drum) => FixHeightRow(
                children: [Text("${drum.name} beats")],
              ),
            ),
          ],
        );
      },
    );
  }
}
