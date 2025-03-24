import 'dart:collection';

import 'package:drums/models/note.dart';
import 'package:flutter/material.dart';

class BeatModel extends ChangeNotifier {
  BeatModel({required List<NoteModel> notes}) : _notes = notes;

  factory BeatModel.generate({
    required NoteValues value,
    required int measure,
  }) {
    return BeatModel(
      notes: List.generate(measure, (_) => NoteModel(value: value)),
    );
  }

  List<NoteModel> _notes;

  UnmodifiableListView<NoteModel> get notes => UnmodifiableListView(_notes);
}
