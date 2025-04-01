import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/measure_unit/model.dart';
import 'package:drums/features/sheet_music/time_signature/model.dart';
import 'package:flutter/material.dart';

class SheetMusicMeasure extends ChangeNotifier {
  SheetMusicMeasure({
    required this.timeSignature,
    required this.drums,
    required this.units,
  });

  factory SheetMusicMeasure.generate({
    required TimeSignature timeSignature,
    required List<Drum> drums,
  }) {
    return SheetMusicMeasure(
      timeSignature: timeSignature,
      drums: drums,
      units: timeSignature.measures
          .map(
            (length) => MeasureUnit.generate(
              noteValue: timeSignature.noteValue,
              length: length,
              drums: drums,
            ),
          )
          .toList(),
    );
  }

  TimeSignature timeSignature;
  List<MeasureUnit> units;
  List<Drum> drums;

  void updateDrumLines(List<Drum> drums) {
    this.drums = drums;
    for (var unit in units) {
      unit.updateDrumLines(drums);
    }
  }

  void updateTimeSignature(TimeSignature newSignature) {
    timeSignature = newSignature;
    units = timeSignature.measures
        .map(
          (length) => MeasureUnit.generate(
            noteValue: timeSignature.noteValue,
            length: length,
            drums: drums,
          ),
        )
        .toList();
    notifyListeners();
  }
}
