import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class NotesEditingController extends ChangeNotifier {
  bool isActive = false;

  List<Set<Note>> selectedNoteGroups = [];

  void toggleActiveStatus() {
    isActive = !isActive;
    notifyListeners();
  }

  void updateSelectedNote(Note note) {
    var group = {note};
    var oldSelection = selectedNoteGroups.expand((group) => group).toSet();
    var newSelection = oldSelection.contains(note) ? <Set<Note>>[] : [group];
    updateSelectedNoteGroups(groups: newSelection);
  }

  void updateSelectedNoteGroups({List<Set<Note>> groups = const []}) {
    var oldSelection = selectedNoteGroups.expand((group) => group).toSet();
    var newSelection = groups.expand((group) => group).toSet();
    var intersection = oldSelection.intersection(newSelection);
    var union = oldSelection.union(newSelection);
    for (var note in union.difference(intersection)) {
      note.changeSelection();
    }
    selectedNoteGroups = groups;
  }

  List<NoteValue> possibleNoteValues() => NoteValue.values;

  void changeSelectedNotesValues(NoteValue noteValue) {}
}
