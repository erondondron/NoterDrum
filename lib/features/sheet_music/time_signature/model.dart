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
}

final sixEights = TimeSignature(
  noteValue: NoteValue.eight,
  measures: const [3, 3],
);

final eightEights = TimeSignature(
  noteValue: NoteValue.eight,
  measures: const [2, 2, 2, 2],
);

final sixteenSixteenths = TimeSignature(
  noteValue: NoteValue.sixteenth,
  measures: const [4, 4, 4, 4],
);
