import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/beat/widget.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/flag.dart';
import 'package:drums/features/sheet_music/staff/lines.dart';
import 'package:drums/features/sheet_music/staff/note.dart';
import 'package:drums/features/sheet_music/staff/rest.dart';
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
            size: Size(beat.viewSize, StaffPainter.height),
            painter: BeatPainter(beat: beat, color: staffColor),
          ),
        );
      },
    );
  }
}

class BeatPainter extends CustomPainter {
  final Beat beat;
  final Color color;

  BeatPainter({
    required this.beat,
    required this.color,
  });

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    var divisions = <BeatDivision, Map<SingleNote, Offset>>{};
    var notesPainter = NotePainter(canvas, color);
    var restPainter = RestPainter(canvas, color);
    for (var division in beat.divisions) {
      var positions = divisions[division] = getNotePositions(division);
      if (positions.isEmpty) {
        restPainter.drawRestSign(division.position, division.noteValue);
        continue;
      }
      for (var entry in positions.entries) {
        notesPainter.drawNoteHead(
          entry.value,
          entry.key.beatLine.drum,
          entry.key.stroke,
        );
      }
    }
    var noteValuesPainter = NoteFlagPainter(canvas, color);
    noteValuesPainter.drawNoteValues(divisions);
  }

  Map<SingleNote, Offset> getNotePositions(BeatDivision division) {
    var positions = <MapEntry<SingleNote, Offset>>[];
    for (var note in division.notes) {
      var drum = note.beatLine.drum;
      var position = NotePainter.getHeadYPosition(drum, note.stroke);
      var offset = Offset(division.position, StaffPainter.height - position);
      positions.add(MapEntry(note, offset));
    }
    positions.sort((a, b) => a.value.dy.compareTo(b.value.dy));

    var offset = false;
    var previous = -double.infinity;
    for (var i = 0; i < positions.length; i++) {
      var entry = positions[i];
      var isNear = entry.value.dy - previous <= StaffPainter.linesGap + 1e-5;
      previous = entry.value.dy;
      offset = isNear ? !offset : false;
      if (offset) {
        var position = Offset(
          offset
              ? entry.value.dx + 2 * NoteFlagPainter.stemOffset
              : entry.value.dx,
          entry.value.dy,
        );
        positions[i] = MapEntry(entry.key, position);
      }
    }
    return Map.fromEntries(positions);
  }
}
