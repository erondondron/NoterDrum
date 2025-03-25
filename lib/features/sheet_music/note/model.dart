import 'package:flutter/cupertino.dart';

enum NoteValues {
  quarter(value: 4),
  eight(value: 8),
  eightTriplet(value: 12),
  sixteenth(value: 16),
  sixteenthTriplet(value: 24),
  thirtySecond(value: 32);

  const NoteValues({required this.value});

  final int value;
}

enum StrokeTypes {
  plain(name: "Plain"),
  off(name: "Off");

  const StrokeTypes({required this.name});

  final String name;
}

class NoteModel extends ChangeNotifier {
  NoteModel({
    NoteValues value = NoteValues.sixteenth,
    StrokeTypes type = StrokeTypes.off,
  })  : _value = value,
        _type = type;

  NoteValues _value;
  StrokeTypes _type;

  NoteValues get value => _value;

  StrokeTypes get type => _type;

  void plainStroke() {
    _type = _type == StrokeTypes.off ? StrokeTypes.plain : StrokeTypes.off;
    notifyListeners();
  }
}
