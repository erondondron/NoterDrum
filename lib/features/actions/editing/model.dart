import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class NotesEditingController extends ChangeNotifier {
  bool isActive = false;

  Set<Note> selectedNotes = {};

  void toggleActiveStatus() {
    isActive = !isActive;
    notifyListeners();
  }

  void updateSelectedNotes({Set<Note> newSelection = const {}}) {
    var intersection = selectedNotes.intersection(newSelection);
    var union = selectedNotes.union(newSelection);
    for (var note in union.difference(intersection)) {
      note.changeSelection();
    }
    selectedNotes = newSelection;
  }

  List<NoteValue> possibleNoteValues() => NoteValue.values;

  void changeSelectedNotesValues(NoteValue noteValue) {}
}
