import 'dart:collection';

import 'package:drums/models/beat.dart';
import 'package:drums/models/drum_set.dart';
import 'package:flutter/material.dart';

class BarModel extends ChangeNotifier {
  BarModel({Map<Drums, List<BeatModel>>? beats}) : _beats = beats ?? {};

  DrumSetModel? _drumSet;
  final Map<Drums, List<BeatModel>> _beats;

  DrumSetModel? get drumSet => _drumSet;

  UnmodifiableListView<BeatModel> getBeats(Drums drum) =>
      UnmodifiableListView(_beats[drum] ?? []);

  void setupDrumSet(DrumSetModel drumSet) {
    _drumSet?.removeListener(_updateDrums);
    _drumSet = drumSet;
    _drumSet!.addListener(_updateDrums);
    _updateDrums();
  }

  @override
  void dispose() {
    _drumSet?.removeListener(_updateDrums);
    super.dispose();
  }

  void _updateDrums() {
    if (_drumSet == null) return notifyListeners();

    final selected = _drumSet!.selected;
    _beats.removeWhere((Drums drum, _) => !selected.contains(drum));
    for (final drum in selected) {
      _beats.putIfAbsent(
        drum,
        () => List.generate(4, (_) => BeatModel.generate()),
      );
    }

    notifyListeners();
  }
}
