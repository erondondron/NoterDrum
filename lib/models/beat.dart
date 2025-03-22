import 'dart:collection';

import 'package:drums/models/note.dart';
import 'package:flutter/material.dart';

class BeatModel extends ChangeNotifier {
  BeatModel({required List<NoteModel> notes}) : _notes = notes;

  factory BeatModel.generate({
    NoteValues value = NoteValues.sixteenth,
    int number = 4,
  }) {
    return BeatModel(
      notes: List.generate(number, (_) => NoteModel(value: value)),
    );
  }

  List<NoteModel> _notes;

  UnmodifiableListView<NoteModel> get notes => UnmodifiableListView(_notes);
}
