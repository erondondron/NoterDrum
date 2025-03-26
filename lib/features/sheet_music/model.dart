import 'package:drums/features/sheet_music/bar/models.dart';
import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/time_signature/model.dart';
import 'package:flutter/material.dart';

class SheetMusicModel extends ChangeNotifier {
  SheetMusicModel({
    DrumSetModel? drumSet,
    List<SheetMusicBarModel>? bars,
  })  : drumSet = drumSet ?? DrumSetModel(),
        bars = bars ?? [SheetMusicBarModel(timeSignature: sixteenSixteenths)] {
    this.drumSet.addListener(_updateDrums);
    _updateDrums();
  }

  @override
  void dispose() {
    drumSet.removeListener(_updateDrums);
    super.dispose();
  }

  final DrumSetModel drumSet;
  final List<SheetMusicBarModel> bars;

  void addNewBar() {
    bars.add(
      SheetMusicBarModel(timeSignature: bars.last.timeSignature)
        ..updateDrums(drumSet.selected),
    );
    notifyListeners();
  }

  void removeBar(SheetMusicBarModel bar) {
    if (bars.length == 1) {
      final newBar = SheetMusicBarModel(timeSignature: bars.last.timeSignature)
        ..updateDrums(drumSet.selected);
      bars.insert(0, newBar);
    }
    bars.remove(bar);
    notifyListeners();
  }

  void _updateDrums() {
    for (SheetMusicBarModel bar in bars) {
      bar.updateDrums(drumSet.selected);
    }
  }
}
