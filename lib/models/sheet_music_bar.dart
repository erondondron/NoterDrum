import 'dart:collection';

import 'package:drums/models/bar.dart';
import 'package:drums/models/drum_set.dart';
import 'package:flutter/material.dart';

class SheetMusicBarModel extends ChangeNotifier {
  SheetMusicBarModel({List<BarModel>? drumBars}) : _bars = drumBars ?? [];

  final List<BarModel> _bars;

  UnmodifiableListView<BarModel> get drumBars => UnmodifiableListView(_bars);

  void updateDrums(List<Drums> drums) {
    _bars.removeWhere((BarModel bar) => !drums.contains(bar.drum));

    final barsDrums = _bars.map((BarModel bar) => bar.drum).toSet();
    final newDrums = drums.toSet().difference(barsDrums);
    _bars.addAll(newDrums.map((Drums drum) => BarModel(drum: drum)));

    notifyListeners();
  }
}
