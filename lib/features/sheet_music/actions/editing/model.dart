import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:flutter/material.dart';

class NotesEditingController extends ChangeNotifier {
  NotesEditingController({required this.drumSet});

  final DrumSet drumSet;

  bool isActive = false;

  Map<Beat, Set<SingleNote>> selectedNotes = {};

  void toggleActiveStatus() {
    isActive = !isActive;
    unselect();
    notifyListeners();
  }

  void unselect() => updateSelectedNoteGroups({});

  void updateSelectedNote(Beat beat, SingleNote note) {
    var newSelectedGroup = {note};
    var oldSelection = selectedNotes.values.expand((group) => group).toSet();
    var newSelection = oldSelection.contains(note)
        ? <Beat, Set<SingleNote>>{}
        : {beat: newSelectedGroup};
    updateSelectedNoteGroups(newSelection);
  }

  void updateSelectedNoteGroups(Map<Beat, Set<SingleNote>> beatNotes) {
    var updatedBeats = beatNotes.keys.toSet();
    updatedBeats.addAll(selectedNotes.keys);
    for (var beat in updatedBeats) {
      beat.selectNotes(newSelection: beatNotes[beat] ?? {});
    }
    selectedNotes = beatNotes;
  }

  List<StrokeType> possibleStrokes() {
    if (selectedNotes.isEmpty) return <StrokeType>[];
    var beatNotes = selectedNotes.entries.first;
    var lines = <BeatLine>{};
    for (var note in beatNotes.value) {
      lines.add(note.beatLine);
    }
    var selectedDrums = lines
        .map((line) => beatNotes.key.notesGrid.indexOf(line))
        .map((index) => drumSet.selected[index])
        .toSet();

    return StrokeType.values
        .where((stroke) => selectedDrums.difference(stroke.filter).isEmpty)
        .toList();
  }

  void changeSelectedStrokeTypes(StrokeType stroke) {
    for (var beatNotes in selectedNotes.entries) {
      for (var note in beatNotes.value) {
        note.stroke = stroke;
      }
      beatNotes.key.generateDivisions();
    }
  }

  List<NoteValue> possibleNoteValues() {
    if (selectedNotes.isEmpty) return <NoteValue>[];
    var shortestPart = NoteValue.values.last.part;
    for (var beatNotes in selectedNotes.values) {
      var lines = <BeatLine, Set<SingleNote>>{};
      for (var note in beatNotes) {
        lines.putIfAbsent(note.beatLine, () => <SingleNote>{}).add(note);
      }
      for (var lineNotes in lines.values) {
        var wholeNote = 0.0;
        for (var note in lineNotes) {
          wholeNote += 1 / note.value.part;
        }
        var noteValuePart = (1 / wholeNote).ceil();
        if (noteValuePart < shortestPart) {
          shortestPart = noteValuePart;
        }
      }
    }
    return NoteValue.values
        .where((note) => note.unit.part >= shortestPart)
        .toList();
  }

  void changeSelectedNotesValues(NoteValue newNoteValue) {
    var newSelection = <Beat, Set<SingleNote>>{};
    for (var beatNotes in selectedNotes.entries) {
      var lines = <BeatLine, Set<SingleNote>>{};
      for (var note in beatNotes.value) {
        lines.putIfAbsent(note.beatLine, () => <SingleNote>{}).add(note);
      }
      for (var lineNotes in lines.entries) {
        changeLineNotesValues(lineNotes.key, lineNotes.value, newNoteValue);
      }
      beatNotes.key.generateDivisions();
      newSelection[beatNotes.key] = beatNotes.key.notesGrid
          .expand((line) => line.singleNotes)
          .where((note) => note.isSelected)
          .toSet();
    }
    selectedNotes = newSelection;
  }

  void changeLineNotesValues(
    BeatLine beatLine,
    Set<Note> selectedNotes,
    NoteValue newNoteValue,
  ) {
    var toProcess = selectedNotes.cast<Note>();
    for (var triplet in beatLine.notes.whereType<Triplet>()) {
      var selected = triplet.notes.toSet().intersection(toProcess);
      toProcess = toProcess.difference(selected);
      if (selected.isEmpty || selected.length == 3) {
        toProcess.add(triplet);
        continue;
      }
      for (var note in selected) {
        note.isValid = false;
      }
    }

    var duration = 0.0;
    var idx = -1;
    for (var note in toProcess) {
      duration += NoteValue.values.last.part / note.value.unit.part;
      idx = beatLine.notes.indexOf(note);
      beatLine.notes.removeAt(idx);
    }
    if (idx < 0) return;

    var isValid = true;
    var noteValue = newNoteValue;
    var availableDuration = duration.round();
    while (availableDuration > 0) {
      var noteDuration = NoteValue.values.last.part ~/ noteValue.unit.part;
      if (noteDuration > availableDuration) {
        var possibleNoteValue = NoteValue.values.firstWhere(
          (note) => note.unit.part > noteValue.unit.part,
          orElse: () => noteValue,
        );
        if (noteValue == possibleNoteValue) break;
        noteValue = possibleNoteValue;
        isValid = false;
        continue;
      }

      availableDuration -= noteDuration;
      var note = Note.generate(value: noteValue)..beatLine = beatLine;
      var singleNotes = note is Triplet ? note.notes : [note as SingleNote];
      for (var singleNote in singleNotes) {
        singleNote.isValid = isValid;
        singleNote.isSelected = true;
      }
      beatLine.notes.insert(idx++, note);
    }
  }
}
