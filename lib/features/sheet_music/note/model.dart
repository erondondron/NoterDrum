import 'package:flutter/material.dart';

enum NoteValue {
  quarter(part: 4),
  eight(part: 8),
  eightTriplet(part: 12),
  sixteenth(part: 16),
  sixteenthTriplet(part: 24),
  thirtySecond(part: 32);

  const NoteValue({required this.part});

  final int part;
}

enum StrokeType {
  plain(name: "Plain"),
  off(name: "Off");

  const StrokeType({required this.name});

  final String name;
}

class NoteModel extends ChangeNotifier {
  NoteModel({
    required this.value,
    this.type = StrokeType.off,
  }) : key = GlobalKey();

  NoteValue value;
  StrokeType type;
  GlobalKey key;

  void plainStroke() {
    type = type == StrokeType.off ? StrokeType.plain : StrokeType.off;
    notifyListeners();
  }
}
