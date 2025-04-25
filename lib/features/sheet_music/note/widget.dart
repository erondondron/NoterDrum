import 'dart:math';

import 'package:drums/features/sheet_music/actions/editing/model.dart';
import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget({
    super.key,
    required this.beat,
    required this.note,
  });

  final Beat beat;
  final SingleNote note;

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesEditingController>(
      builder: (BuildContext context, NotesEditingController controller, _) {
        return SizedBox(
          width: note.viewSize,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: controller.isActive
                  ? () => controller.updateSelectedNote(beat, note)
                  : () => beat.changeNoteStroke(note: note),
              behavior: HitTestBehavior.translucent,
              child: NoteView(note: note),
            ),
          ),
        );
      },
    );
  }
}

class NoteView extends StatelessWidget {
  static const double height = 40;
  static const double borderWidth = 1.5;
  static const double outerDiameter = 30;
  static const double innerDiameter = outerDiameter - borderWidth * 2;

  const NoteView({super.key, required this.note});

  final SingleNote note;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: note.key,
      width: Note.minViewSize,
      height: height,
      child: Center(
        child: Container(
          width: outerDiameter,
          height: outerDiameter,
          decoration: _noteDecoration(context),
          child: Center(child: _noteStrokeView(context)),
        ),
      ),
    );
  }

  BoxDecoration _noteDecoration(BuildContext context) {
    final containerColor = Theme.of(context).colorScheme.secondaryContainer;
    final borderColor = Theme.of(context).colorScheme.onSecondaryContainer;
    return BoxDecoration(
      color: containerColor,
      shape: BoxShape.circle,
      border: Border.all(
        color: note.isSelected ? Colors.transparent : borderColor,
        width: borderWidth,
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

  Widget _noteStrokeView(BuildContext context) {
    switch (note.stroke) {
      case (StrokeType.off):
        return SizedBox.shrink();
      case StrokeType.plain:
        return _plainStrokeView(context: context);
      case StrokeType.accent:
        return _accentStrokeView(context: context);
      case StrokeType.ghost:
        return _ghostStrokeView(context: context);
      case StrokeType.rimClick:
        return _rimClickView(context: context);
      case StrokeType.rimShot:
        return _rimShotView(context: context);
      case StrokeType.flam:
        return _flamStrokeView(context: context);
      case StrokeType.opened:
        return _rimShotView(context: context);
      case StrokeType.foot:
        return _rimClickView(context: context);
      case StrokeType.bell:
        return _bellStrokeView(context: context);
      case StrokeType.choke:
        return _rimClickView(context: context);
    }
  }

  Widget _plainStrokeView({required BuildContext context, Widget? child}) {
    final fillColor = Theme.of(context).colorScheme.onSurface;
    return Container(
      width: innerDiameter,
      height: innerDiameter,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }

  Widget _accentStrokeView({required BuildContext context}) {
    final containerColor = Theme.of(context).colorScheme.secondaryContainer;
    return _plainStrokeView(
      context: context,
      child: Center(
        child: Icon(
          Icons.keyboard_arrow_right,
          color: containerColor,
          size: innerDiameter,
        ),
      ),
    );
  }

  Widget _ghostStrokeView({required BuildContext context}) {
    final fillColor = Theme.of(context).colorScheme.onSurface;
    final diameter = innerDiameter * 0.4;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _rimClickView({required BuildContext context, Widget? child}) {
    final fillColor = Theme.of(context).colorScheme.onSurface;
    final containerColor = Theme.of(context).colorScheme.secondaryContainer;
    final diameter = innerDiameter * 0.7;
    return Container(
      width: innerDiameter,
      height: innerDiameter,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: containerColor,
            shape: BoxShape.circle,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _rimShotView({required BuildContext context}) {
    return _rimClickView(
      context: context,
      child: Center(
        child: _ghostStrokeView(context: context),
      ),
    );
  }

  Widget _flamStrokeView({required BuildContext context}) {
    final containerColor = Theme.of(context).colorScheme.secondaryContainer;
    return _plainStrokeView(
      context: context,
      child: Center(
        child: Container(
          height: innerDiameter,
          width: 5,
          color: containerColor,
        ),
      ),
    );
  }

  Widget _bellStrokeView({required BuildContext context}) {
    final fillColor = Theme.of(context).colorScheme.onSurface;
    final size = innerDiameter / 2;
    return Transform.rotate(
      angle: pi / 4,
      child: Container(
        width: size,
        height: size,
        color: fillColor,
      ),
    );
  }
}
