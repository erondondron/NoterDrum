import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/time_signature/model.dart';
import 'package:flutter/material.dart';

class SheetMusic extends ChangeNotifier {
  SheetMusic({
    required this.name,
    required this.drumSet,
    required this.measures,
  }) {
    drumSet.addListener(_updateMeasureDrumLines);
  }

  factory SheetMusic.generate({String name = "NewGroove"}) {
    var drumSet = DrumSetModel();
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

  final String name;
  final DrumSetModel drumSet;
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
}
