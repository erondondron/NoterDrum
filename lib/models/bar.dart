import 'package:drums/models/drum_set.dart';
import 'package:flutter/material.dart';

class BarModel extends ChangeNotifier {
  BarModel({List<Drums>? beats}) : _beats = beats ?? const [];

  DrumSetModel? _drumSet;
  List<Drums> _beats;

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
    _beats = _drumSet?.selected ?? [];
    notifyListeners();
  }

  List<Drums> get selectedDrums => _beats;
}
