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

  MeasureUnitDrumLine.fromJson(Map<String, dynamic> json)
      : drum = Drum.values.firstWhere(
          (drum) => drum.name == json["drum"] as String,
        ),
        notes = (json["notes"] as List<Map<String, dynamic>>)
            .map((note) => Note.fromJson(note))
            .toList();

  Map<String, dynamic> toJson() => {
        "drum": drum.name,
        "notes": notes.map((note) => note.toJson()).toList(),
      };
}
