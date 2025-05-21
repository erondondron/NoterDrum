import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/beat/widget.dart';
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
  final StaffBeat beat;
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
    for (var division in beat.divisions) {
      if (division.notes.isEmpty) {
        restPainter.drawRestSign(division.position, division.noteValue);
        continue;
      }
      for (var note in division.notes) {
        notesPainter.drawNoteHead(note);
      }
      noteValuePainter.drawStem(division);
    }
    for (var division in beat.singleNotes) {
      noteValuePainter.drawSingleNoteFlag(division);
    }
    for (var group in beat.beamGroups) {
      noteValuePainter.drawBeam(group);
    }
  }
}
