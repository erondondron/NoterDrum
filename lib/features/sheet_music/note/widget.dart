import 'package:drums/features/actions/editing/model.dart';
import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/measure_unit_line/model.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<Note, NotesEditingController>(
      builder: (BuildContext context, Note note,
          NotesEditingController controller, _) {
        return SizedBox(
          width: note.width,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: controller.isActive
                  ? () => select(note, controller, context)
                  : note.changeStroke,
              behavior: HitTestBehavior.translucent,
              child: NoteView(note: note),
            ),
          ),
        );
      },
    );
  }

  void select(
    Note note,
    NotesEditingController controller,
    BuildContext context,
  ) =>
      controller.updateSelectedNote(
        Provider.of<SheetMusicMeasure>(context, listen: false),
        Provider.of<MeasureUnitDrumLine>(context, listen: false),
        note,
      );
}

class NoteView extends StatelessWidget {
  static const double outerHeight = 40;
  static const double innerSize = 30;

  const NoteView({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: note.key,
      width: Note.minWidth,
      height: outerHeight,
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: _noteDecoration(context),
        ),
      ),
    );
  }

  BoxDecoration _noteDecoration(BuildContext context) {
    final containerColor = Theme.of(context).colorScheme.secondaryContainer;
    final fillColor = Theme.of(context).colorScheme.onSurface;
    final borderColor = Theme.of(context).colorScheme.onSecondaryContainer;
    return BoxDecoration(
      color: note.type == StrokeType.off ? containerColor : fillColor,
      shape: BoxShape.circle,
      border: Border.all(
        color: note.isSelected ? Colors.transparent : borderColor,
        width: 1.5,
      ),
      boxShadow: _noteSelection(context),
    );
  }

  List<BoxShadow> _noteSelection(BuildContext context) {
    if (!note.isSelected) return [];
    final selectionColor = Theme.of(context).colorScheme.primary;
    final errorColor = Theme.of(context).colorScheme.error;
    return [
      BoxShadow(
        color: note.isValid ? selectionColor : errorColor,
        blurRadius: 7.5,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: selectionColor.withValues(alpha: 0.5),
        blurRadius: 15,
        spreadRadius: 4,
      ),
    ];
  }
}
