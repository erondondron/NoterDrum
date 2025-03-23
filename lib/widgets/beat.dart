import 'package:drums/models/beat.dart';
import 'package:drums/models/note.dart';
import 'package:drums/shared/fix_height_row.dart';
import 'package:drums/widgets/note.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeatWidget extends StatelessWidget {
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: NoteWidget(),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
