import 'package:drums/edit_grid/configuration.dart';
import 'package:drums/models/drum_set.dart';
import 'package:drums/models/note.dart';
import 'package:drums/models/note_value.dart';
import 'package:drums/staff/models.dart';
import 'package:flutter/material.dart';

class BeatLine {
  final List<Note> notes;

  GlobalKey key = GlobalKey();
  Drum drum;

  List<SingleNote> get singleNotes => notes
      .expand((note) => note is Triplet ? note.notes : [note as SingleNote])
      .toList();

  BeatLine({required this.notes, required this.drum}) {
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
  late StaffNoteGroup staffModel;
  double viewSize = 0;

  Beat({
    required this.notesGrid,
    required this.noteValue,
    required this.length,
  }) {
    createStaffModel();
  }

  factory Beat.generate({
    required DrumSet drumSet,
    required NoteValue noteValue,
    required int length,
  }) {
    noteGenerator(_) => Note.generate(value: noteValue);
    lineGenerator(int idx) => BeatLine(
          notes: List.generate(length ~/ noteValue.length, noteGenerator),
          drum: drumSet.selected[idx],
        );
    return Beat(
      noteValue: noteValue,
      length: length,
      notesGrid: List.generate(drumSet.selected.length, lineGenerator),
    );
  }

  void createStaffModel() {
    calculateNotesWidth();
    staffModel = StaffConverter.convertBeat(this);
    notifyListeners();
  }

  void calculateNotesWidth() {
    if (notesGrid.isEmpty) {
      viewSize = 0;
      return;
    }
    var notes = notesGrid.expand((line) => line.notes);
    var values = notes.map((note) => note.value).toSet();
    var shortest = values.reduce((a, b) => a.part > b.part ? a : b);
    var dw = EditGridConfiguration.noteWidth / shortest.duration.value;

    var tripletSpreaders = {NoteValue.thirtySecond, NoteValue.sixteenth};
    if (values.contains(NoteValue.eighthTriplet)) {
      tripletSpreaders.add(NoteValue.eighth);
      if (values.intersection(tripletSpreaders).isNotEmpty) dw *= 2;
    } else if (values.contains(NoteValue.sixteenthTriplet)) {
      if (values.intersection(tripletSpreaders).isNotEmpty) dw *= 2;
    }

    for (var gridLine in notesGrid) {
      for (var note in gridLine.notes) {
        note.viewSize = note.value.unit.duration.value * dw;
        if (note is Triplet) {
          var tripletNoteSize = note.viewSize / 3;
          for (var tripletNote in note.notes) {
            tripletNote.viewSize = tripletNoteSize;
          }
        }
      }
    }
    viewSize = notesGrid.first.notes
        .map((note) => note.viewSize)
        .reduce((a, b) => a + b);
  }

  void addLine(int idx, Drum drum) {
    noteGenerator(_) => Note.generate(value: noteValue);
    var newLine = BeatLine(
      notes: List.generate(length, noteGenerator),
      drum: drum,
    );
    notesGrid.insert(idx, newLine);
    createStaffModel();
  }

  void removeLine(int idx) {
    notesGrid.removeAt(idx);
    createStaffModel();
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
        (note.stroke == StrokeType.rest ? StrokeType.plain : StrokeType.rest);
    createStaffModel();
  }

  factory Beat.fromJson(DrumSet drumSet, Map<String, dynamic> json) {
    var notesGrid = <BeatLine>[];
    var rawNotes = json["notes"] as List<dynamic>;
    for (var (idx, drum) in drumSet.selected.indexed) {
      var notes = [
        for (var rawNote in rawNotes[idx] as List<dynamic>)
          Note.fromJson(rawNote as Map<String, dynamic>)
      ];
      notesGrid.add(BeatLine(notes: notes, drum: drum));
    }
    return Beat(
      notesGrid: notesGrid,
      noteValue: NoteValue.values.firstWhere(
        (value) => value.part == json["note_value"] as int,
      ),
      length: json["length"] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        "notes": notesGrid
            .map((line) => line.notes.map((note) => note.toJson()).toList())
            .toList(),
        "note_value": noteValue.part,
        "length": length,
      };
}
