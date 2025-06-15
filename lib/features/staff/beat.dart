import 'package:drums/features/edit_grid/beat.dart';
import 'package:drums/features/models/beat.dart';
import 'package:drums/features/staff/configuration.dart';
import 'package:drums/features/staff/models.dart';
import 'package:drums/features/staff/note.dart';
import 'package:drums/features/staff/note_value.dart';
import 'package:drums/features/staff/rest.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeatStaffWidget extends StatelessWidget {
  const BeatStaffWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var staffColor = Theme.of(context).colorScheme.onSurface;
    return Consumer<Beat>(
      builder: (BuildContext context, Beat beat, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: BeatWidget.padding),
          child: CustomPaint(
            size: Size(beat.viewSize, FiveLinesSettings.height),
            painter: BeatPainter(beat: beat.staffModel, color: staffColor),
          ),
        );
      },
    );
  }
}

class BeatPainter extends CustomPainter {
  final StaffNoteGroup beat;
  final Color color;

  BeatPainter({
    required this.beat,
    required this.color,
  });

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, FiveLinesSettings.center);

    var notesPainter = NotePainter(color: color, canvas: canvas);
    var noteValuePainter = NoteValuePainter(canvas: canvas, color: color);
    var restPainter = RestPainter(color: color, canvas: canvas);
    for (var stack in beat.stacks) {
      if (stack.notes.isEmpty) {
        restPainter.drawRestSign(stack.x, stack.noteValue);
      }
      for (var note in stack.notes) {
        notesPainter.drawNoteHead(note);
      }
      if (stack.stemStart == null || stack.stemEnd == null) continue;
      noteValuePainter.drawStem(stack.stemStart!, stack.stemEnd!);
    }
    for (var stack in beat.singleNotes) {
      if (stack.stemEnd == null) continue;
      noteValuePainter.drawSingleNoteFlag(stack.stemEnd!, stack.noteValue);
    }
    for (var group in beat.subgroups.values) {
      noteValuePainter.drawBeam(group: group);
    }
  }
}
