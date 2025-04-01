import 'package:flutter/material.dart';

enum Drum {
  crash(order: 0, name: "Crash", icon: "crash.svg"),
  hiHat(order: 1, name: "Hi-Hat", icon: "hi_hat.svg"),
  ride(order: 2, name: "Ride", icon: "ride.svg"),
  tom1(order: 3, name: "Tom 1", icon: "tom_1.svg"),
  tom2(order: 4, name: "Tom 2", icon: "tom_2.svg"),
  snare(order: 5, name: "Snare", icon: "snare.svg"),
  tom3(order: 6, name: "Tom 3", icon: "tom_3.svg"),
  kick(order: 7, name: "Kick", icon: "kick.svg");

  const Drum({
    required this.order,
    required this.name,
    required String icon,
  }) : icon = "assets/icons/$icon";

  final int order;
  final String name;
  final String icon;
}

class DrumSetPanelController extends ChangeNotifier {
  bool isHidden = true;

  void toggleHiding() {
    isHidden = !isHidden;
    notifyListeners();
  }
}

class DrumSetModel extends ChangeNotifier {
  DrumSetModel({List<Drum>? selected})
      : selected = selected ?? [Drum.hiHat, Drum.snare, Drum.kick];

  final List<Drum> selected;

  List<Drum> get unselected =>
      Drum.values.where((Drum drum) => !selected.contains(drum)).toList();

  void add(Drum drum) {
    selected.add(drum);
    selected.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  void remove(Drum drum) {
    selected.remove(drum);
    notifyListeners();
  }
}
