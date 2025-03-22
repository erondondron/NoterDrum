import 'dart:collection';

import 'package:flutter/cupertino.dart';

enum Drums {
  crash(order: 0, name: "Crash", icon: "crash.svg"),
  hiHat(order: 1, name: "Hi-Hat", icon: "hi_hat.svg"),
  ride(order: 2, name: "Ride", icon: "ride.svg"),
  tom1(order: 3, name: "Tom 1", icon: "tom_1.svg"),
  tom2(order: 4, name: "Tom 2", icon: "tom_2.svg"),
  snare(order: 5, name: "Snare", icon: "snare.svg"),
  tom3(order: 6, name: "Tom 3", icon: "tom_3.svg"),
  kick(order: 7, name: "Kick", icon: "kick.svg");

  const Drums({
    required this.order,
    required this.name,
    required String icon,
  }) : icon = "assets/icons/$icon";

  final int order;
  final String name;
  final String icon;
}

class DrumSetModel extends ChangeNotifier {
  DrumSetModel({
    List<Drums> selected = const [Drums.hiHat, Drums.snare, Drums.kick],
    bool isHidden = true,
  })  : _selected = selected.toList(),
        _isHidden = isHidden;

  final List<Drums> _selected;
  bool _isHidden;

  UnmodifiableListView<Drums> get selected => UnmodifiableListView(_selected);

  UnmodifiableListView<Drums> get unselected => UnmodifiableListView(
      Drums.values.where((Drums drum) => !_selected.contains(drum)));

  bool get isHidden => _isHidden;

  void add(Drums drum) {
    _selected.add(drum);
    _selected.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  void remove(Drums drum) {
    _selected.remove(drum);
    notifyListeners();
  }

  void toggleHiding() {
    _isHidden = !_isHidden;
    notifyListeners();
  }
}
