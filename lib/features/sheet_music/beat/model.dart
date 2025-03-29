import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class BeatModel extends ChangeNotifier {
  BeatModel({required this.notes}) {
    for (var note in notes) {
      note.beat = this;
    }
    _setupMaxNoteValue();
  }

  factory BeatModel.generate({
    required NoteValue value,
    required int measure,
  }) {
    var notes = List.generate(measure, (_) => NoteModel(value: value));
    return BeatModel(notes: notes);
  }

  List<NoteModel> notes;
  NoteValue maxNoteValue = NoteValue.thirtySecond;

  void _setupMaxNoteValue() {
    var wholeNote = 0.0;
    for (var note in notes) {
      wholeNote += 1 / note.value.part;
    }
    var noteValuePart = (1 / wholeNote).floor();
    maxNoteValue = NoteValue.values.firstWhere(
      (note) => note.part >= noteValuePart,
    );
  }
}
