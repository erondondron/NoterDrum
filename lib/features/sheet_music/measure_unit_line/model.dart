import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class MeasureUnitDrumLine extends ChangeNotifier {
  MeasureUnitDrumLine({
    required this.drum,
    required this.notes,
  });

  factory MeasureUnitDrumLine.generate({
    required Drum drum,
    required NoteValue noteValue,
    required int length,
  }) {
    var notes = List.generate(length, (_) => Note(value: noteValue));
    return MeasureUnitDrumLine(drum: drum, notes: notes);
  }

  GlobalKey key = GlobalKey();

  Drum drum;
  List<Note> notes;
}
