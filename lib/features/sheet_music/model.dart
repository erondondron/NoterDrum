import 'dart:collection';

import 'package:drums/features/sheet_music/bar/models.dart';
import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:flutter/material.dart';

class SheetMusicModel extends ChangeNotifier {
  SheetMusicModel({
    DrumSetModel? drumSet,
    List<SheetMusicBarModel>? bars,
  })  : _drumSet = drumSet ?? DrumSetModel(),
        _bars = bars ?? [SheetMusicBarModel()] {
    _updateDrums();
    _drumSet.addListener(_updateDrums);
  }

  @override
  void dispose() {
    _drumSet.removeListener(_updateDrums);
    super.dispose();
  }

  final DrumSetModel _drumSet;
  final List<SheetMusicBarModel> _bars;

  DrumSetModel get drumSet => _drumSet;

  UnmodifiableListView<SheetMusicBarModel> get bars =>
      UnmodifiableListView(_bars);

  void addNewBar() {
    _bars.add(
      SheetMusicBarModel(timeSignature: _bars.last.timeSignature)
        ..updateDrums(_drumSet.selected),
    );
    notifyListeners();
  }

  void removeBar(SheetMusicBarModel bar) {
    if (_bars.length == 1) {
      final newBar = SheetMusicBarModel(timeSignature: _bars.last.timeSignature)
        ..updateDrums(_drumSet.selected);
      _bars.insert(0, newBar);
    }
    _bars.remove(bar);
    notifyListeners();
  }

  void _updateDrums() {
    final selectedDrums = _drumSet.selected;
    for (SheetMusicBarModel bar in _bars) {
      bar.updateDrums(selectedDrums);
    }
  }
}
