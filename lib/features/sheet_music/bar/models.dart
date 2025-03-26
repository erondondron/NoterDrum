import 'package:drums/features/sheet_music/beat/model.dart';
import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/time_signature/model.dart';
import 'package:flutter/material.dart';

class BarModel extends ChangeNotifier {
  BarModel({required this.drum, required this.beats});

  factory BarModel.generate({
    required Drum drum,
    required TimeSignature timeSignature,
  }) {
    return BarModel(
      drum: drum,
      beats: timeSignature.measures
          .map(
            (int measure) => BeatModel.generate(
              measure: measure,
              value: timeSignature.noteValue,
            ),
          )
          .toList(),
    );
  }

  final Drum drum;
  final List<BeatModel> beats;
}

class SheetMusicBarModel extends ChangeNotifier {
  SheetMusicBarModel({
    required this.timeSignature,
    List<BarModel>? drumBars,
  }) : drumBars = drumBars ?? [];

  TimeSignature timeSignature;
  List<BarModel> drumBars;

  void updateDrums(List<Drum> drums) {
    drumBars.removeWhere((BarModel bar) => !drums.contains(bar.drum));

    final barsDrums = drumBars.map((BarModel bar) => bar.drum).toSet();
    final newDrums = drums.toSet().difference(barsDrums);
    drumBars.addAll(newDrums.map((Drum drum) =>
        BarModel.generate(drum: drum, timeSignature: timeSignature)));

    drumBars.sort((a, b) => a.drum.order.compareTo(b.drum.order));
    notifyListeners();
  }

  void updateTimeSignature(TimeSignature timeSignature) {
    final barsDrums = drumBars.map((BarModel bar) => bar.drum).toSet();
    drumBars = barsDrums
        .map((Drum drum) =>
            BarModel.generate(drum: drum, timeSignature: timeSignature))
        .toList();

    timeSignature = timeSignature;
    notifyListeners();
  }
}
