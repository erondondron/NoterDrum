import 'package:drums/features/models/note.dart';
import 'package:flutter/material.dart';

class TimeSignature extends ChangeNotifier {
  TimeSignature({
    required this.noteValue,
    required this.measures,
  });

  NoteValue noteValue;
  List<int> measures;

  String get label {
    int nominator = measures.reduce((a, b) => a + b);
    return "$nominator / ${noteValue.part}";
  }

  void increaseNoteValue() {
    if (noteValue == NoteValue.values.last) return;
    var idx = NoteValue.values.indexOf(noteValue);
    noteValue = NoteValue.values[idx + 1];
    var beatLength = noteValue.part ~/ NoteValue.quarter.part;
    measures = List.generate(4, (_) => beatLength);
    notifyListeners();
  }

  void decreaseNoteValue() {
    if (noteValue == NoteValue.values.first) return;
    var idx = NoteValue.values.indexOf(noteValue);
    noteValue = NoteValue.values[idx - 1];
    var beatLength = noteValue.part ~/ NoteValue.quarter.part;
    measures = List.generate(4, (_) => beatLength);
    notifyListeners();
  }

  void changeBeatLength(int unitIndex, int changeValue) {
    var newLength = measures[unitIndex] + changeValue;
    newLength > 0
        ? measures[unitIndex] = newLength
        : measures.removeAt(unitIndex);
    notifyListeners();
  }

  void addBeat() {
    var beatLength = noteValue.part ~/ NoteValue.quarter.part;
    measures.add(beatLength);
    notifyListeners();
  }

  TimeSignature.fromJson(Map<String, dynamic> json)
      : noteValue = NoteValue.values.firstWhere(
          (note) => note.part == json["note_value"] as int,
        ),
        measures = (json["measures"] as List<dynamic>).cast<int>();

  Map<String, dynamic> toJson() => {
        "note_value": noteValue.part,
        "measures": measures,
      };
}

final sixEights = TimeSignature(
  noteValue: NoteValue.eighth,
  measures: const [3, 3],
);

final eightEights = TimeSignature(
  noteValue: NoteValue.eighth,
  measures: const [2, 2, 2, 2],
);

final sixteenSixteenths = TimeSignature(
  noteValue: NoteValue.sixteenth,
  measures: const [4, 4, 4, 4],
);
