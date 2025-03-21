import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  List<Instruments> get selected => _selected.toList();
}

class SheetMusicEditor extends StatefulWidget {
  const SheetMusicEditor({super.key});

  @override
  State<SheetMusicEditor> createState() => _SheetMusicEditorState();
}

class _SheetMusicEditorState extends State<SheetMusicEditor> {
  final InstrumentsController controller = InstrumentsController();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      InstrumentsPanel(controller: controller),
    ]);
  }
}

class InstrumentsPanel extends StatefulWidget {
  const InstrumentsPanel({super.key, required this.controller});

  final InstrumentsController controller;

  @override
  State<InstrumentsPanel> createState() => _InstrumentsPanelState();
}

class _InstrumentsPanelState extends State<InstrumentsPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.controller.selected
          .map((instrument) => instrumentRow(instrument))
          .toList(),
    );
  }

  Widget instrumentRow(Instruments instrument) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          instrumentIcon(instrument.icon),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(instrument.name),
          ),
        ],
      ),
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
}
