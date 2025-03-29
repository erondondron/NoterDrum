import 'package:drums/features/sheet_music/measure_unit_line/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class NotesEditingController extends ChangeNotifier {
  bool isActive = false;

  Map<MeasureUnitDrumLine, Set<Note>> selectedNotes = {};

  void toggleActiveStatus() {
    updateSelectedNoteGroups();
    isActive = !isActive;
    notifyListeners();
  }

  void updateSelectedNote(MeasureUnitDrumLine drumLine, Note note) {
    var group = {note};
    var oldSelection = selectedNotes.values.expand((group) => group).toSet();
    var newSelection = oldSelection.contains(note)
        ? <MeasureUnitDrumLine, Set<Note>>{}
        : {drumLine: group};
    updateSelectedNoteGroups(groups: newSelection);
  }

  void updateSelectedNoteGroups(
      {Map<MeasureUnitDrumLine, Set<Note>> groups = const {}}) {
    var oldSelection = selectedNotes.values.expand((g) => g).toSet();
    for (var note in oldSelection) {
      note.isValid = true;
    }
    var newSelection = groups.values.expand((group) => group).toSet();
    var intersection = oldSelection.intersection(newSelection);
    var union = oldSelection.union(newSelection);
    for (var note in union.difference(intersection)) {
      note.changeSelection();
    }
    selectedNotes = groups;
  }

  List<NoteValue> possibleNoteValues() {
    if (selectedNotes.isEmpty) return NoteValue.values;
    var minDuration = NoteValue.values.last.duration;
    for (var group in selectedNotes.values) {
      var wholeNote = 0.0;
      for (var note in group) {
        wholeNote += 1 / note.value.part;
      }
      var noteValuePart = (1 / wholeNote).ceil();
      if (noteValuePart < minDuration) {
        minDuration = noteValuePart;
      }
    }
    return NoteValue.values
        .where((note) => note.duration >= minDuration)
        .toList();
  }

  void changeSelectedNotesValues(NoteValue newNoteValue) {
    var oldSelection = selectedNotes;
    updateSelectedNoteGroups();
    var newSelection = <MeasureUnitDrumLine, Set<Note>>{};
    for (var drumLineNotes in oldSelection.entries) {
      newSelection[drumLineNotes.key] = {};
      var triplets = drumLineNotes.key.notes
          .where((note) => note.value.count == 3)
          .toList();

      var selectedNotes = drumLineNotes.value.toSet();
      for (int i = 0; i < triplets.length; i += 3) {
        var tripletNotes = triplets.sublist(i, (i + 3)).toSet();
        var selectedTriples = tripletNotes.intersection(drumLineNotes.value);
        if (selectedTriples.isEmpty || selectedTriples.length == 3) continue;
        for (var note in selectedTriples) {
          note.isValid = false;
          selectedNotes.remove(note);
          newSelection[drumLineNotes.key]!.add(note);
        }
      }

      var duration = 0.0;
      var idx = -1;
      for (var note in selectedNotes) {
        duration += NoteValue.values.last.part / note.value.part;
        idx = drumLineNotes.key.notes.indexOf(note);
        drumLineNotes.key.notes.remove(note);
      }
      if (idx < 0) continue;

      var isValid = true;
      var noteValue = newNoteValue;
      var availableDuration = duration.round();
      while (availableDuration > 0) {
        var noteDuration = NoteValue.values.last.part ~/ noteValue.duration;
        if (noteDuration > availableDuration) {
          var possibleNoteValue = NoteValue.values.firstWhere(
            (note) => note.duration > noteValue.duration,
            orElse: () => noteValue,
          );
          if (noteValue == possibleNoteValue) break;
          noteValue = possibleNoteValue;
          isValid = false;
        }

        availableDuration -= noteDuration;
        for (int i = 0; i < noteValue.count; i++) {
          var note = Note(value: noteValue);
          drumLineNotes.key.notes.insert(idx++, note);
          newSelection[drumLineNotes.key]!.add(note);
          note.isValid = isValid;
        }
      }
    }
    updateSelectedNoteGroups(groups: newSelection);
    for (var drumLine in selectedNotes.keys){
      drumLine.notifyListeners();
    }
  }
}
