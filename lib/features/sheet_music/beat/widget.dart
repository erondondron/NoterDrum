import 'package:drums/features/sheet_music/beat/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:drums/shared/fix_height_row.dart';
import 'package:drums/features/sheet_music/note/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeatWidget extends StatelessWidget {
  static const double padding = 5;

  const BeatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BeatModel>(
      builder: (BuildContext context, BeatModel beat, _) {
        return FixHeightRow(
          children: beat.notes
              .map(
                (NoteModel note) => ChangeNotifierProvider.value(
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
