import 'dart:math';

import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/measure_unit_line/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class MeasureUnit extends ChangeNotifier {
  GlobalKey key = GlobalKey();
  double width = 0;

  List<MeasureUnitDrumLine> drumLines;
  NoteValue noteValue;
  int length;

  MeasureUnit({
    required this.noteValue,
    required this.length,
    required this.drumLines,
  }) {
    calculateNotesWidth();
    for (var line in drumLines) {
      line.addListener(notifyListeners);
    }
  }

  factory MeasureUnit.generate({
    required NoteValue noteValue,
    required int length,
    required List<Drum> drums,
  }) {
    return MeasureUnit(
      noteValue: noteValue,
      length: length,
      drumLines: drums
          .map((drum) => MeasureUnitDrumLine.generate(
              drum: drum, noteValue: noteValue, length: length))
          .toList(),
    );
  }

  @override
  void dispose() {
    for (var line in drumLines) {
      line.removeListener(notifyListeners);
    }
    super.dispose();
  }

  void addDrumLine(MeasureUnitDrumLine newLine) {
    newLine.addListener(notifyListeners);
    var idx = drumLines.indexWhere(
      (selected) => selected.drum.order > newLine.drum.order,
    );
    idx > 0 ? drumLines.insert(idx, newLine) : drumLines.add(newLine);
  }

  void removeDrumLine(MeasureUnitDrumLine line) {
    line.removeListener(notifyListeners);
    drumLines.remove(line);
  }

  void updateDrumLines(List<Drum> drums) {
    for (var line
        in drumLines.where((line) => !drums.contains(line.drum)).toList()) {
      removeDrumLine(line);
    }

    final unitDrums = drumLines.map((drumLine) => drumLine.drum).toSet();
    final newDrums = drums.toSet().difference(unitDrums);
    for (var drum in newDrums) {
      var newLine = MeasureUnitDrumLine.generate(
          drum: drum, noteValue: noteValue, length: length);
      addDrumLine(newLine);
    }

    calculateNotesWidth();
    notifyListeners();
  }

  void calculateNotesWidth() {
    var minNoteValue = drumLines
        .expand((line) => line.notes)
        .reduce((min, note) => min.value.part > note.value.part ? min : note)
        .value;

    for (var line in drumLines) {
      var lineWidth = 0.0;
      for (var note in line.notes) {
        var relative = minNoteValue.part / note.value.part;
        note.width = relative * Note.minWidth;
        lineWidth += note.width;
      }
      width = max(width, lineWidth);
    }
  }

  MeasureUnit.fromJson(Map<String, dynamic> json)
      : drumLines = (json["drum_lines"] as List<dynamic>)
            .map((line) => MeasureUnitDrumLine.fromJson(
                  line as Map<String, dynamic>,
                ))
            .toList(),
        noteValue = NoteValue.values.firstWhere(
          (note) => note.part == json["note_value"] as int,
        ),
        length = json["length"] as int;

  Map<String, dynamic> toJson() => {
        "drum_lines": drumLines.map((line) => line.toJson()).toList(),
        "note_value": noteValue.part,
        "length": length,
      };
}
