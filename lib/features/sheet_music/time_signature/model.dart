import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/cupertino.dart';

class TimeSignature extends ChangeNotifier {
  TimeSignature({
    required this.noteValue,
    required this.measures,
  });

  NoteValues noteValue;
  List<int> measures;

  String get label {
    int nominator = measures.reduce((a, b) => a + b);
    return "$nominator / ${noteValue.value}";
  }
}

final sixEights = TimeSignature(
  noteValue: NoteValues.eight,
  measures: const [3, 3],
);

final eightEights = TimeSignature(
  noteValue: NoteValues.eight,
  measures: const [2, 2, 2, 2],
);

final sixteenSixteenths = TimeSignature(
  noteValue: NoteValues.sixteenth,
  measures: const [4, 4, 4, 4],
);
