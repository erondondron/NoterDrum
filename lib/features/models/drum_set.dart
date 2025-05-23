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

  final int order;
  final String name;
  final String icon;

  const Drum({
    required this.order,
    required this.name,
    required String icon,
  }) : icon = "assets/icons/$icon";
}

class DrumSetPanelController extends ChangeNotifier {
  bool isHidden = true;

  void toggleHiding() {
    isHidden = !isHidden;
    notifyListeners();
  }
}

class DrumSet extends ChangeNotifier {
  final List<Drum> selected;

  void Function(int)? newDrumCallback;
  void Function(int)? removedDrumCallback;

  List<Drum> get unselected =>
      Drum.values.where((Drum drum) => !selected.contains(drum)).toList();

  DrumSet({List<Drum>? selected})
      : selected = selected ?? [Drum.hiHat, Drum.snare, Drum.kick];

  void add(Drum drum) {
    var idx = selected.indexWhere((selected) => selected.order > drum.order);
    idx = idx >= 0 ? idx : selected.length;
    selected.insert(idx, drum);
    notifyListeners();
    if (newDrumCallback != null) {
      newDrumCallback!(idx);
    }
  }

  void remove(Drum drum) {
    var idx = selected.indexWhere((selected) => selected == drum);
    selected.removeAt(idx);
    notifyListeners();
    if (removedDrumCallback != null) {
      removedDrumCallback!(idx);
    }
  }

  DrumSet.fromJson(Map<String, dynamic> json)
      : selected = (json["selected"] as List<dynamic>)
            .map((selected) => Drum.values
                .firstWhere((drum) => drum.name == selected as String))
            .toList();

  Map<String, dynamic> toJson() => {
        "selected": selected.map((drum) => drum.name).toList(),
      };
}
