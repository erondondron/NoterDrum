import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

enum Instruments {
  crash(order: 0, name: "Crash", icon: "crash.svg"),
  hiHat(order: 1, name: "Hi-Hat", icon: "hi_hat.svg"),
  ride(order: 2, name: "Ride", icon: "ride.svg"),
  tom1(order: 3, name: "Tom 1", icon: "tom_1.svg"),
  tom2(order: 4, name: "Tom 2", icon: "tom_2.svg"),
  snare(order: 5, name: "Snare", icon: "snare.svg"),
  tom3(order: 6, name: "Tom 3", icon: "tom_3.svg"),
  kick(order: 7, name: "Kick", icon: "kick.svg");

  const Instruments({
    required this.order,
    required this.name,
    required String icon,
  }) : icon = "assets/icons/$icon";

  final int order;
  final String name;
  final String icon;
}

class InstrumentsController extends ChangeNotifier {
  final List<Instruments> _selected = [
    Instruments.crash,
    Instruments.ride,
    Instruments.hiHat,
    Instruments.tom1,
    Instruments.tom2,
    Instruments.snare,
    Instruments.tom3,
    Instruments.kick,
  ];

  UnmodifiableListView<Instruments> get selected =>
      UnmodifiableListView(_selected);

  void add(Instruments instrument) {
    _selected.add(instrument);
    _selected.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  void remove(Instruments instrument) {
    _selected.remove(instrument);
    notifyListeners();
  }
}

class SheetMusicEditor extends StatelessWidget {
  const SheetMusicEditor({super.key});

  @override
  Widget build(BuildContext context) => Row(children: [InstrumentsPanel()]);
}

class InstrumentsPanel extends StatefulWidget {
  const InstrumentsPanel({super.key});

  @override
  State<InstrumentsPanel> createState() => _InstrumentsPanelState();
}

class _InstrumentsPanelState extends State<InstrumentsPanel> {
  static const double _rowHeight = 30;

  @override
  Widget build(BuildContext context) {
    return Consumer<InstrumentsController>(
      builder: (BuildContext context, InstrumentsController controller, _) {
        return IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.selected
                .map((instrument) => instrumentRow(instrument, controller))
                .toList(),
          ),
        );
      },
    );
  }

  Widget instrumentRow(
    Instruments instrument,
    InstrumentsController controller,
  ) {
    return SizedBox(
      height: _rowHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          instrumentDescription(instrument),
          removeButton(instrument, controller),
        ],
      ),
    );
  }

  Widget instrumentDescription(Instruments instrument) {
    return Row(
      children: [
        instrumentIcon(instrument.icon),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 20),
          child: Text(instrument.name),
        ),
      ],
    );
  }

  Widget instrumentIcon(String iconPath) {
    final color = Theme.of(context).iconTheme.color!;
    final theme = ColorFilter.mode(color, BlendMode.srcIn);
    return SizedBox(
      width: 24,
      child: SvgPicture.asset(iconPath, colorFilter: theme),
    );
  }

  Widget removeButton(
    Instruments instrument,
    InstrumentsController controller,
  ) {
    return GestureDetector(
      onTap: () => controller.remove(instrument),
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
          height: _rowHeight,
          width: _rowHeight,
          child: Icon(Icons.close_outlined, size: 17)),
    );
  }
}
