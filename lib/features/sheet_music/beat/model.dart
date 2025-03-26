import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class BeatModel extends ChangeNotifier {
  BeatModel({required this.notes});

  factory BeatModel.generate({
    required NoteValue value,
    required int measure,
  }) {
    var notes = List.generate(measure, (_) => NoteModel(value: value));
    return BeatModel(notes: notes);
  }

  List<NoteModel> notes;
}
