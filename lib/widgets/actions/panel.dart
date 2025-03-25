import 'package:drums/widgets/actions/edit.dart';
import 'package:drums/widgets/actions/play.dart';
import 'package:flutter/material.dart';

import 'metronome.dart';

class ActionsPanel extends StatelessWidget {
  const ActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NoteEditPanel(),
        SizedBox(width: 10),
        PlayButton(),
        SizedBox(width: 10),
        MetronomePanel(),
      ],
    );
  }
}
