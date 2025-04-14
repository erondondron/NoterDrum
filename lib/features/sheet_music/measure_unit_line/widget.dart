import 'package:drums/features/sheet_music/measure_unit_line/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:drums/shared/widgets/fix_height_row.dart';
import 'package:drums/features/sheet_music/note/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeasureUnitLineWidget extends StatelessWidget {
  const MeasureUnitLineWidget({super.key, required this.unitLine});

  final MeasureUnitDrumLine unitLine;

  @override
  Widget build(BuildContext context) {
    return FixHeightRow(
      key: unitLine.key,
      children: unitLine.notes
          .map(
            (Note note) => ChangeNotifierProvider.value(
              value: note,
              child: NoteWidget(note: note),
            ),
          )
          .toList(),
    );
  }
}
