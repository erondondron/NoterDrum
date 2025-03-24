import 'dart:collection';

import 'package:drums/models/beat.dart';
import 'package:drums/models/drum_set.dart';
import 'package:flutter/material.dart';

class BarModel extends ChangeNotifier {
  BarModel({required this.drum, List<BeatModel>? beats})
      : _beats = beats ?? List.generate(4, (_) => BeatModel.generate());

  final Drums drum;
  final List<BeatModel> _beats;

  UnmodifiableListView<BeatModel> get beats => UnmodifiableListView(_beats);
}
