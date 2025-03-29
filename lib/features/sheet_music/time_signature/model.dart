import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/cupertino.dart';

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
    notifyListeners();
  }

  void decreaseNoteValue() {
    if (noteValue == NoteValue.values.first) return;
    var idx = NoteValue.values.indexOf(noteValue);
    noteValue = NoteValue.values[idx - 1];
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
    measures.add(1);
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
