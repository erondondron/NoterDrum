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

class SheetMusic extends ChangeNotifier {
  SheetMusic({
    List<Drums> selectedDrums = const [Drums.hiHat, Drums.snare, Drums.kick],
  }) : _selectedDrums = selectedDrums.toList();

  final List<Drums> _selectedDrums;

  UnmodifiableListView<Drums> get selectedDrums =>
      UnmodifiableListView(_selectedDrums);

  UnmodifiableListView<Drums> get unselectedDrums => UnmodifiableListView(
      Drums.values.where((Drums drum) => !_selectedDrums.contains(drum)));

  void addDrum(Drums drum) {
    _selectedDrums.add(drum);
    _selectedDrums.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  void removeDrum(Drums drum) {
    _selectedDrums.remove(drum);
    notifyListeners();
  }
}
