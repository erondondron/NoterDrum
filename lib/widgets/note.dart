import 'package:drums/models/note.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteModel>(
      builder: (BuildContext context, NoteModel beat, _) {
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              width: 1.5,
            )
          ),
        );
      },
    );
  }
}
