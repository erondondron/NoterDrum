import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/measure_unit_line/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class NotesEditingController extends ChangeNotifier {
  bool isActive = false;

  Map<MeasureUnitDrumLine, Set<Note>> selectedNotes = {};
  SheetMusicMeasure? selectedMeasure;

  void toggleActiveStatus() {
    isActive = !isActive;
    unselect();
    notifyListeners();
  }

  void unselect() => updateSelectedNoteGroups(null, {});

  void updateSelectedNote(
    SheetMusicMeasure measure,
    MeasureUnitDrumLine drumLine,
    Note note,
  ) {
    var group = {note};
    var oldSelection = selectedNotes.values.expand((group) => group).toSet();
    var newSelection = oldSelection.contains(note)
        ? <MeasureUnitDrumLine, Set<Note>>{}
        : {drumLine: group};
    updateSelectedNoteGroups(measure, newSelection);
  }

  void updateSelectedNoteGroups(
    SheetMusicMeasure? measure,
    Map<MeasureUnitDrumLine, Set<Note>> lineNotes,
  ) {
    var oldSelection = selectedNotes.values.expand((g) => g).toSet();
    for (var note in oldSelection) {
      note.isValid = true;
    }
    var newSelection = lineNotes.values.expand((group) => group).toSet();
    var intersection = oldSelection.intersection(newSelection);
    var union = oldSelection.union(newSelection);
    for (var note in union.difference(intersection)) {
      note.changeSelection();
    }
    selectedNotes = lineNotes;
    selectedMeasure = measure;
  }

  List<StrokeType> possibleStrokes() {
    if (selectedNotes.isEmpty) return <StrokeType>[];
    var drums = selectedNotes.keys.map((line) => line.drum).toSet();
    return StrokeType.values
        .where((stroke) => drums.difference(stroke.filter).isEmpty)
        .toList();
  }

  void changeSelectedStrokeTypes(StrokeType stroke) {
    var notes = selectedNotes.values.expand((notes) => notes).toList();
    if (notes.isEmpty) return;
    for (var note in notes) {
      note.changeStroke(strokeType: stroke);
    }
  }

  List<NoteValue> possibleNoteValues() {
    if (selectedNotes.isEmpty) return <NoteValue>[];
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
    for (var drumLineNotes in selectedNotes.entries) {
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
        }
      }

      var duration = 0.0;
      var idx = -1;
      for (var note in selectedNotes) {
        duration += NoteValue.values.last.part / note.value.part;
        idx = drumLineNotes.key.notes.indexOf(note);
        drumLineNotes.key.notes.remove(note);

        note.isValid = true;
        note.isSelected = false;
        drumLineNotes.value.remove(note);
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

          note.isValid = isValid;
          note.isSelected = true;
          drumLineNotes.value.add(note);
        }
      }
    }
    for (var unit in selectedMeasure!.units) {
      unit.calculateNotesWidth();
    }
    selectedMeasure!.notifyListeners();
  }
}
