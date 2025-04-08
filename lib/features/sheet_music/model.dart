import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/time_signature/model.dart';
import 'package:flutter/material.dart';

class SheetMusic extends ChangeNotifier {
  static const int version = 1;

  SheetMusic({
    required this.name,
    required this.drumSet,
    required this.measures,
  }) {
    drumSet.addListener(_updateMeasureDrumLines);
  }

  factory SheetMusic.generate({String name = "NewGroove"}) {
    var drumSet = DrumSet();
    var measure = SheetMusicMeasure.generate(
      timeSignature: sixteenSixteenths,
      drums: drumSet.selected,
    );
    return SheetMusic(name: name, drumSet: drumSet, measures: [measure]);
  }

  @override
  void dispose() {
    drumSet.removeListener(_updateMeasureDrumLines);
    super.dispose();
  }

  String? storagePath;

  final String name;
  final DrumSet drumSet;
  final List<SheetMusicMeasure> measures;

  void addNewMeasure() {
    measures.add(
      SheetMusicMeasure.generate(
        timeSignature: measures.last.timeSignature,
        drums: drumSet.selected,
      ),
    );
    notifyListeners();
  }

  void removeMeasure(SheetMusicMeasure measure) {
    if (measures.length == 1) {
      final newMeasure = SheetMusicMeasure.generate(
        timeSignature: measures.last.timeSignature,
        drums: drumSet.selected,
      );
      measures.insert(0, newMeasure);
    }
    measures.remove(measure);
    notifyListeners();
  }

  void _updateMeasureDrumLines() {
    for (SheetMusicMeasure measure in measures) {
      measure.updateDrumLines(drumSet.selected);
    }
  }

  SheetMusic.fromJson(Map<String, dynamic> json)
      : name = json["name"] as String,
        drumSet = DrumSet.fromJson(
          json["drum_set"] as Map<String, dynamic>,
        ),
        measures = (json["measures"] as List<Map<String, dynamic>>)
            .map((measure) => SheetMusicMeasure.fromJson(measure))
            .toList();

  Map<String, dynamic> toJson() => {
        "name": name,
        "drum_set": drumSet.toJson(),
        "measures": measures.map((measure) => measure.toJson()).toList(),
      };
}
