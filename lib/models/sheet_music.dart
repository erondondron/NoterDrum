import 'dart:collection';

import 'package:drums/models/drum_set.dart';
import 'package:drums/models/sheet_music_bar.dart';
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
    _bars.remove(bar);
    return _bars.isEmpty ? addNewBar() : notifyListeners();
  }

  void _updateDrums() {
    final selectedDrums = _drumSet.selected;
    for (SheetMusicBarModel bar in _bars) {
      bar.updateDrums(selectedDrums);
    }
  }
}
