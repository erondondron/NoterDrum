import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteWidget extends StatelessWidget {
  static const double outerSize = 40;
  static const double innerSize = 30;

  const NoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteModel>(
      builder: (BuildContext context, NoteModel note, _) {
        return GestureDetector(
          onTap: note.plainStroke,
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            width: outerSize,
            height: outerSize,
            child: Center(
              child: Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  color: note.type == StrokeTypes.off
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    width: 1.5,
                  ),
                ),
              ),
            )
          ),
        );
      },
    );
  }
}
