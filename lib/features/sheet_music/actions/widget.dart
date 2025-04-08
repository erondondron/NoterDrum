import 'package:drums/features/sheet_music/actions/editing/widget.dart';
import 'package:drums/features/sheet_music/actions/playback/widget.dart';
import 'package:flutter/material.dart';

import 'metronome/widget.dart';

class ActionsPanel extends StatelessWidget {
  static const double size = 50;

  const ActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NotesEditingPanel(),
        SizedBox(width: 10),
        PlayButton(),
        SizedBox(width: 10),
        MetronomePanel(),
      ],
    );
  }
}
