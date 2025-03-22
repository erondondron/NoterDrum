import 'dart:collection';

import 'package:drums/models/bar.dart';
import 'package:drums/models/drum_set.dart';
import 'package:flutter/material.dart';

class SheetMusicModel extends ChangeNotifier {
  SheetMusicModel({
    DrumSetModel? drumSet,
    List<BarModel>? bars,
  })  : _drumSet = drumSet ?? DrumSetModel(),
        _bars = bars ?? [BarModel()] {
    for (BarModel bar in _bars) {
      bar.setupDrumSet(_drumSet);
    }
  }

  final DrumSetModel _drumSet;
  final List<BarModel> _bars;

  DrumSetModel get drumSet => _drumSet;

  UnmodifiableListView<BarModel> get bars => UnmodifiableListView(_bars);

  void addNewBar() {
    _bars.add(BarModel()..setupDrumSet(_drumSet));
    notifyListeners();
  }

  void removeBar(BarModel bar) {
    _bars.remove(bar);
    if (_bars.isEmpty) {
      return addNewBar();
    }
    notifyListeners();
  }
}
