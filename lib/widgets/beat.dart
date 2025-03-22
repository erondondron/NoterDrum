import 'package:drums/models/beat.dart';
import 'package:drums/shared/fix_height_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeatWidget extends StatelessWidget {
  const BeatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BeatModel>(
      builder: (BuildContext context, BeatModel beat, _) {
        return FixHeightRow(
          children: List.generate(
            beat.notes.length,
            (_) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
        return Text("${beat.notes.length} notes");
      },
    );
  }
}
