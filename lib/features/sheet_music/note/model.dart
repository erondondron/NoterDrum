import 'package:flutter/material.dart';

enum NoteValue {
  quarter(part: 4, count: 1),
  eighth(part: 8, count: 1),
  eighthTriplet(part: 12, count: 3),
  sixteenth(part: 16, count: 1),
  sixteenthTriplet(part: 24, count: 3),
  thirtySecond(part: 32, count: 1);

  const NoteValue({
    required this.part,
    required this.count,
  });

  final int part;
  final int count;

  int get duration => part ~/ count;
}

enum StrokeType {
  plain(name: "Plain"),
  off(name: "Off");

  const StrokeType({required this.name});

  final String name;
}

class Note extends ChangeNotifier {
  Note({
    required this.value,
    this.type = StrokeType.off,
  });

  GlobalKey key = GlobalKey();
  bool isSelected = false;

  NoteValue value;
  StrokeType type;

  void changeStroke({StrokeType stroke = StrokeType.plain}) {
    type = type == StrokeType.off ? stroke : StrokeType.off;
    notifyListeners();
  }

  void changeSelection() {
    isSelected = !isSelected;
    notifyListeners();
  }
}
