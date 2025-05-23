import 'package:drums/features/models/beat.dart';
import 'package:drums/features/models/drum_set.dart';
import 'package:drums/features/models/time_signature.dart';
import 'package:flutter/material.dart';

class GrooveMeasure extends ChangeNotifier {
  TimeSignature timeSignature;
  DrumSet drumSet;
  List<Beat> beats;

  GrooveMeasure({
    required this.timeSignature,
    required this.drumSet,
    required this.beats,
  });

  factory GrooveMeasure.generate({
    required TimeSignature timeSignature,
    required DrumSet drumSet,
  }) {
    return GrooveMeasure(
      timeSignature: timeSignature,
      drumSet: drumSet,
      beats: timeSignature.measures
          .map(
            (length) => Beat.generate(
              noteValue: timeSignature.noteValue,
              drumSet: drumSet,
              length: length,
            ),
          )
          .toList(),
    );
  }

  void addNewBeatsLine(int idx) {
    for (var beat in beats) {
      beat.addLine(idx, drumSet.selected[idx]);
    }
  }

  void removeBeatsLine(int idx) {
    for (var beat in beats) {
      beat.removeLine(idx);
    }
  }

  void updateTimeSignature(TimeSignature newSignature) {
    timeSignature = newSignature;
    beats = timeSignature.measures
        .map(
          (length) => Beat.generate(
            noteValue: timeSignature.noteValue,
            drumSet: drumSet,
            length: length,
          ),
        )
        .toList();
    notifyListeners();
  }

  GrooveMeasure.fromJson(this.drumSet, Map<String, dynamic> json)
      : timeSignature = TimeSignature.fromJson(
          json["time_signature"] as Map<String, dynamic>,
        ),
        beats = (json["beats"] as List<dynamic>)
            .map((beat) => Beat.fromJson(beat as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        "time_signature": timeSignature.toJson(),
        "beats": beats.map((beat) => beat.toJson()).toList(),
      };
}
