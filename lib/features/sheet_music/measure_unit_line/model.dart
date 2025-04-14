import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class MeasureUnitDrumLine extends ChangeNotifier {
  GlobalKey key = GlobalKey();

  Drum drum;
  List<Note> notes;

  MeasureUnitDrumLine({
    required this.drum,
    required this.notes,
  }) {
    for (var note in notes) {
      note.addListener(notifyListeners);
    }
  }

  factory MeasureUnitDrumLine.generate({
    required Drum drum,
    required NoteValue noteValue,
    required int length,
  }) {
    var notes = List.generate(length, (_) => Note(value: noteValue));
    return MeasureUnitDrumLine(drum: drum, notes: notes);
  }

  @override
  void dispose() {
    for (var note in notes) {
      note.removeListener(notifyListeners);
    }
    super.dispose();
  }

  void addNote(int index, Note note) {
    note.addListener(notifyListeners);
    notes.insert(index, note);
  }

  void removeNote(Note note) {
    note.removeListener(notifyListeners);
    notes.remove(note);
  }

  MeasureUnitDrumLine.fromJson(Map<String, dynamic> json)
      : drum = Drum.values.firstWhere(
          (drum) => drum.name == json["drum"] as String,
        ),
        notes = (json["notes"] as List<dynamic>)
            .map((note) => Note.fromJson(note as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        "drum": drum.name,
        "notes": notes.map((note) => note.toJson()).toList(),
      };
}
