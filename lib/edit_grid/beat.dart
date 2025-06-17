import 'package:drums/edit_grid/note.dart';
import 'package:drums/models/beat.dart';
import 'package:drums/shared/fix_height_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeatWidget extends StatelessWidget {
  static const double padding = 13;

  const BeatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Beat>(
      builder: (BuildContext context, Beat beat, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            key: beat.key,
            children: beat.notesGrid
                .map(
                  (beatLine) => FixHeightRow(
                    key: beatLine.key,
                    children: beatLine.singleNotes
                        .map((note) => NoteWidget(beat: beat, note: note))
                        .toList(),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
