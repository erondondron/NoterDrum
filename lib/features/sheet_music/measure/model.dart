import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/measure_unit/model.dart';
import 'package:drums/features/sheet_music/time_signature/model.dart';
import 'package:flutter/material.dart';

class SheetMusicMeasure extends ChangeNotifier {
  TimeSignature timeSignature;
  List<MeasureUnit> units;
  List<Drum> drums;

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

  SheetMusicMeasure.fromJson(Map<String, dynamic> json)
      : timeSignature = TimeSignature.fromJson(
          json["time_signature"] as Map<String, dynamic>,
        ),
        units = (json["units"] as List<dynamic>)
            .map((unit) => MeasureUnit.fromJson(unit as Map<String, dynamic>))
            .toList(),
        drums = (json["drums"] as List<dynamic>)
            .map((selected) => Drum.values
                .firstWhere((drum) => drum.name == selected as String))
            .toList();

  Map<String, dynamic> toJson() => {
        "time_signature": timeSignature.toJson(),
        "units": units.map((unit) => unit.toJson()).toList(),
        "drums": drums.map((drum) => drum.name).toList(),
      };
}
