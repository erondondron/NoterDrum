import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/measure_unit_line/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';

class MeasureUnit extends ChangeNotifier {
  MeasureUnit({
    required this.noteValue,
    required this.length,
    required this.drumLines,
  }) {
    calculateNotesWidth();
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

  GlobalKey key = GlobalKey();

  List<MeasureUnitDrumLine> drumLines;
  NoteValue noteValue;
  int length;

  void updateDrumLines(List<Drum> drums) {
    drumLines.removeWhere((drumLine) => !drums.contains(drumLine.drum));

    final unitDrums = drumLines.map((drumLine) => drumLine.drum).toSet();
    final newDrums = drums.toSet().difference(unitDrums);
    final newLines = newDrums.map((drum) => MeasureUnitDrumLine.generate(
        drum: drum, noteValue: noteValue, length: length));
    drumLines.addAll(newLines);

    drumLines.sort((a, b) => a.drum.order.compareTo(b.drum.order));
    notifyListeners();
  }

  void calculateNotesWidth() {
    var minNoteValue = drumLines
        .expand((line) => line.notes)
        .reduce((min, note) => min.value.part > note.value.part ? min : note)
        .value;

    for (var line in drumLines) {
      for (var note in line.notes) {
        var relative = minNoteValue.part / note.value.part;
        note.width = relative * Note.minWidth;
      }
    }
  }

  MeasureUnit.fromJson(Map<String, dynamic> json)
      : drumLines = (json["drum_lines"] as List<Map<String, dynamic>>)
            .map((line) => MeasureUnitDrumLine.fromJson(line))
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
