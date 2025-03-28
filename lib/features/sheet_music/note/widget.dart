import 'package:drums/features/actions/editing/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Map<NoteValue, double> notesPadding = {
  NoteValue.quarter: 20,
  NoteValue.eight: 10,
  NoteValue.eightTriplet: 7.5,
  NoteValue.sixteenth: 5,
  NoteValue.sixteenthTriplet: 2.5,
  NoteValue.thirtySecond: 0,
};

class NoteWidget extends StatelessWidget {
  const NoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NoteModel, NotesEditingModel>(
      builder: (BuildContext context, NoteModel note,
          NotesEditingModel controller, _) {
        return Padding(
          padding: EdgeInsets.only(right: notesPadding[note.value]!),
          child: GestureDetector(
            onTap: controller.isActive
                ? () => controller.updateSelectedNotes(
                    newSelection: {note}.difference(controller.selectedNotes))
                : note.plainStroke,
            behavior: HitTestBehavior.translucent,
            child: NoteBox(note: note),
          ),
        );
      },
    );
  }
}

class NoteBox extends StatelessWidget {
  static const double outerHeight = 40;
  static const double outerWidth = 35;
  static const double innerSize = 30;

  const NoteBox({super.key, required this.note});

  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    final containerColor = Theme.of(context).colorScheme.secondaryContainer;
    final fillColor = Theme.of(context).colorScheme.onSurface;
    final borderColor = Theme.of(context).colorScheme.onSecondaryContainer;
    final selectionColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      key: note.key,
      width: outerWidth,
      height: outerHeight,
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            color: note.type == StrokeType.off ? containerColor : fillColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: note.selected ? Colors.transparent : borderColor,
              width: 1.5,
            ),
            boxShadow: note.selected
                ? [
                    BoxShadow(
                      color: selectionColor,
                      blurRadius: 7.5,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: selectionColor.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}
