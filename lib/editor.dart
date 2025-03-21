import 'package:flutter/material.dart';

class Instrument {
  const Instrument({
    required this.id,
    required this.name,
    required this.icon,
  });

  final int id;
  final String name;
  final IconData icon;
}

class InstrumentsController extends ChangeNotifier {
  final List<Instrument> instruments = [
    Instrument(id: 0, name: "Crash", icon: Icons.music_note),
    Instrument(id: 1, name: "Hi-Hat", icon: Icons.music_note),
    Instrument(id: 2, name: "Ride", icon: Icons.music_note),
    Instrument(id: 3, name: "Tom 1", icon: Icons.music_note),
    Instrument(id: 4, name: "Tom 2", icon: Icons.music_note),
    Instrument(id: 5, name: "Snare", icon: Icons.music_note),
    Instrument(id: 6, name: "Tom 3", icon: Icons.music_note),
    Instrument(id: 7, name: "Kick", icon: Icons.music_note),
  ];

  final Set<int> _selected = {0, 1, 2, 3, 4, 5, 6, 7};

  List<Instrument> get selected =>
      instruments.where((i) => _selected.contains(i.id)).toList();
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

  Widget instrumentRow(Instrument instrument) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(instrument.icon),
          Text(instrument.name),
        ],
      ),
    );
  }
}
