import 'dart:collection';

import 'package:drums/models/beat.dart';
import 'package:drums/models/drum_set.dart';
import 'package:drums/models/time_signature.dart';
import 'package:flutter/material.dart';

class BarModel extends ChangeNotifier {
  BarModel({required this.drum, required List<BeatModel> beats})
      : _beats = beats;

  factory BarModel.generate({
    required Drums drum,
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

  final Drums drum;
  final List<BeatModel> _beats;

  UnmodifiableListView<BeatModel> get beats => UnmodifiableListView(_beats);
}
