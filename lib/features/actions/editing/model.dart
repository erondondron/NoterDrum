import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class NotesEditingModel extends ChangeNotifier {
  bool isActive = false;

  Set<NoteModel> selectedNotes = {};

  void toggle() {
    isActive = !isActive;
    notifyListeners();
  }

  void updateSelectedNotes({Set<NoteModel> newSelection = const {}}) {
    var intersection = selectedNotes.intersection(newSelection);
    var union = selectedNotes.union(newSelection);
    for (var note in union.difference(intersection)) {
      note.select();
    }
    selectedNotes = newSelection;
  }

  List<NoteValue> possibleNoteValues() {
    if (selectedNotes.isEmpty) return NoteValue.values;
    var maxNoteValues = selectedNotes.map((note) => note.beat.maxNoteValue);
    var maxNoteValue = maxNoteValues.reduce((a, b) => a.part < b.part ? a : b);
    return NoteValue.values
        .where((note) => note.part >= maxNoteValue.part)
        .toList();
  }

  void changeSelectedNotesValues(NoteValue noteValue) {}
}
