import 'package:drums/features/sheet_music/note/model.dart';
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
    var unitLength = noteValue.part ~/ NoteValue.quarter.part;
    measures = List.generate(4, (_) => unitLength);
    notifyListeners();
  }

  void decreaseNoteValue() {
    if (noteValue == NoteValue.values.first) return;
    var idx = NoteValue.values.indexOf(noteValue);
    noteValue = NoteValue.values[idx - 1];
    var unitLength = noteValue.part ~/ NoteValue.quarter.part;
    measures = List.generate(4, (_) => unitLength);
    notifyListeners();
  }

  void changeUnitLength(int unitIndex, int changeValue) {
    var newLength = measures[unitIndex] + changeValue;
    newLength > 0
        ? measures[unitIndex] = newLength
        : measures.removeAt(unitIndex);
    notifyListeners();
  }

  void addUnit() {
    var unitLength = noteValue.part ~/ NoteValue.quarter.part;
    measures.add(unitLength);
    notifyListeners();
  }
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
