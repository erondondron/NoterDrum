import 'package:drums/features/sheet_music/measure_unit_line/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:drums/shared/widgets/fix_height_row.dart';
import 'package:drums/features/sheet_music/note/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeasureUnitLineWidget extends StatelessWidget {
  const MeasureUnitLineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MeasureUnitDrumLine>(
      builder: (BuildContext context, MeasureUnitDrumLine measureUnitLine, _) {
        return FixHeightRow(
          key: measureUnitLine.key,
          children: measureUnitLine.notes
              .map(
                (Note note) => ChangeNotifierProvider.value(
                  value: note,
                  child: NoteWidget(),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
