import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/measure_unit_line/model.dart';
import 'package:flutter/material.dart';

const Set<Drum> snareAndToms = {Drum.snare, Drum.tom1, Drum.tom2, Drum.tom3};
const Set<Drum> cymbals = {Drum.crash, Drum.ride};

enum NoteValue {
  quarter(part: 4, count: 1),
  eighth(part: 8, count: 1),
  eighthTriplet(part: 12, count: 3),
  sixteenth(part: 16, count: 1),
  sixteenthTriplet(part: 24, count: 3),
  thirtySecond(part: 32, count: 1);

  final int part;
  final int count;

  int get duration => part ~/ count;

  const NoteValue({
    required this.part,
    required this.count,
  });
}

enum StrokeType {
  opened(name: "Opened", drums: {Drum.hiHat}),
  bell(name: "Bell", drums: cymbals),
  choke(name: "Choke", drums: cymbals),
  accent(name: "Accent"),
  plain(name: "Plain"),
  ghost(name: "Ghost"),
  rimClick(name: "Rim click", drums: snareAndToms),
  rimShot(name: "Rim shot", drums: snareAndToms),
  buzz(name: "Buzz", drums: snareAndToms),
  flam(name: "Flam"),
  foot(name: "Foot", drums: {Drum.hiHat}),
  off(name: "Off");

  final String name;
  final Set<Drum>? drums;

  Set<Drum> get filter => drums ?? Drum.values.toSet();

  const StrokeType({
    required this.name,
    this.drums,
  });
}

class Note extends ChangeNotifier {
  static const double minWidth = 35;

  GlobalKey key = GlobalKey();
  bool isSelected = false;
  bool isValid = true;
  double width = minWidth;

  NoteValue value;
  StrokeType type;

  Note({
    required this.value,
    this.type = StrokeType.off,
  });

  void changeStroke({StrokeType? strokeType}) {
    type = strokeType ??
        (type == StrokeType.off ? StrokeType.plain : StrokeType.off);
    notifyListeners();
  }

  void changeSelection() {
    isSelected = !isSelected;
    notifyListeners();
  }

  Note.fromJson(Map<String, dynamic> json)
      : value = NoteValue.values.firstWhere(
          (value) => value.part == json["value"] as int,
        ),
        type = StrokeType.values.firstWhere(
          (type) => type.name == json["type"] as String,
        );

  Map<String, dynamic> toJson() => {
        "value": value.part,
        "type": type.name,
      };
}
