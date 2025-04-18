import 'package:drums/features/sheet_music/note/models.dart';
import 'package:flutter/material.dart';

class BeatDivision {
  final Map<int, Note> notes = {};
}

class BeatLine {
  final List<Note> notes;

  GlobalKey key = GlobalKey();

  List<SingleNote> get singleNotes => notes
      .expand((note) => note is Triplet ? note.notes : [note as SingleNote])
      .toList();

  BeatLine({required this.notes}) {
    for (var note in notes) {
      note.beatLine = this;
    }
  }
}

class Beat extends ChangeNotifier {
  List<BeatLine> notesGrid;
  NoteValue noteValue;
  int length;

  GlobalKey key = GlobalKey();
  List<BeatDivision> divisions = [];

  Beat({
    required this.notesGrid,
    required this.noteValue,
    required this.length,
  }) {
    generateDivisions();
  }

  factory Beat.generate({
    required NoteValue noteValue,
    required int length,
    required int width,
  }) {
    noteGenerator(_) => Note.generate(value: noteValue);
    lineGenerator(_) => BeatLine(
          notes: List.generate(length ~/ noteValue.length, noteGenerator),
        );
    return Beat(
      noteValue: noteValue,
      length: length,
      notesGrid: List.generate(width, lineGenerator),
    );
  }

  void generateDivisions() {
    if (notesGrid.isEmpty) {
      divisions = [];
      return;
    }
    var notes = notesGrid.expand((line) => line.notes).toList();
    var shortestNoteUnit =
        notes.reduce((a, b) => a.value.unit.part > b.value.unit.part ? a : b);
    var shortestNote =
        notes.reduce((a, b) => a.value.part > b.value.part ? a : b);

    var beatDuration = NoteValue.values.last.part * length ~/ noteValue.part;
    var divValue = shortestNoteUnit.value.unit;
    var divCount = beatDuration * divValue.part ~/ NoteValue.values.last.part;
    var newDivisions = List.generate(divCount, (_) => BeatDivision());

    for (var i = 0; i < notesGrid.length; i++) {
      var gridLine = notesGrid[i];
      var divIdx = 0;
      for (var note in gridLine.notes) {
        newDivisions[divIdx].notes[i] = note;
        divIdx += divValue.part ~/ note.value.unit.part;
        note.viewSize =
            shortestNote.value.part / note.value.unit.part * Note.minViewSize;
        if (note is Triplet) {
          var tripletNoteSize = note.viewSize / 3;
          for (var tripletNote in note.notes) {
            tripletNote.viewSize = tripletNoteSize;
          }
        }
      }
    }
    divisions = newDivisions;
    notifyListeners();
  }

  void addLine(int idx) {
    noteGenerator(_) => Note.generate(value: noteValue);
    var newLine = BeatLine(notes: List.generate(length, noteGenerator));
    notesGrid.insert(idx, newLine);
    generateDivisions();
  }

  void removeLine(int idx) {
    notesGrid.removeAt(idx);
    generateDivisions();
  }

  void selectNotes({required Set<SingleNote> newSelection}) {
    var oldSelection = notesGrid
        .expand((gridLine) => gridLine.singleNotes)
        .where((note) => note.isSelected)
        .toSet();
    var invalid = oldSelection.where((note) => !note.isValid).toSet();
    if (newSelection == oldSelection && invalid.isEmpty) return;

    for (var note in oldSelection) {
      note.isSelected = false;
      note.isValid = true;
    }
    for (var note in newSelection) {
      note.isSelected = true;
    }
    notifyListeners();
  }

  void changeNoteStroke({required SingleNote note, StrokeType? stroke}) {
    note.stroke = stroke ??
        (note.stroke == StrokeType.off ? StrokeType.plain : StrokeType.off);
    generateDivisions();
  }

  // FIXME
  factory Beat.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  // FIXME
  Map<String, dynamic> toJson() => throw UnimplementedError();
}
