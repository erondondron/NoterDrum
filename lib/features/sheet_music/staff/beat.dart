import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/beat/widget.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/beam.dart';
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
  static const double linesGap = StaffPainter.linesGap;

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
    canvas.translate(0, StaffPainter.heightHalf + linesGap * 2);
    var divisions = <BeatDivision, Map<SingleNote, Offset>>{};
    var restPainter = RestPainter(color: color, canvas: canvas);
    var notesPainter = NotePainter(color: color, canvas: canvas);
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
    drawNoteValues(canvas, divisions);
  }

  Map<SingleNote, Offset> getNotePositions(BeatDivision division) {
    var positions = <MapEntry<SingleNote, Offset>>[];
    for (var note in division.notes) {
      var drum = note.beatLine.drum;
      var y = NotePainter.getHeadStaffLinesPosition(drum, note.stroke);
      var x = division.position - y * NotePainter.stemIncline;
      positions.add(MapEntry(note, Offset(x, y)));
    }
    positions.sort((a, b) => a.value.dy.compareTo(b.value.dy));

    var offset = false;
    var previous = -double.infinity;
    for (var i = 0; i < positions.length; i++) {
      var entry = positions[i];
      var isNear = entry.value.dy - previous <= linesGap + 1e-5;
      previous = entry.value.dy;
      offset = isNear ? !offset : false;
      if (offset) {
        var position = Offset(
          offset ? entry.value.dx + 2 * NotePainter.stemOffset : entry.value.dx,
          entry.value.dy,
        );
        positions[i] = MapEntry(entry.key, position);
      }
    }
    return Map.fromEntries(positions);
  }

  void drawNoteValues(
    Canvas canvas,
    Map<BeatDivision, Map<SingleNote, Offset>> divisionNotes,
  ) {
    var beamPainter = NotesBeamPainter(color: color, canvas: canvas);
    var flagPainter = NoteFlagPainter(color: color, canvas: canvas);

    var divisions = divisionNotes.keys.toList();
    var eighthGroups = <BeatDivision, List<BeatDivision>>{
      for (var group in beamPainter.getBeamGroups(divisions, NoteValue.eighth))
        group.first: group
    };
    var divIdx = 0;
    while (divIdx < divisions.length) {
      var division = divisions[divIdx++];
      var group = eighthGroups[division];
      if (group != null && group.length > 1) {
        beamPainter.drawBeamGroup(group, NoteValue.eighth);
        divIdx += group.length - 1;
        continue;
      }
      if (division.notes.isEmpty) continue;

      var positions = divisionNotes[division]!.values;
      var lowerNote = positions.reduce((a, b) => a.dy > b.dy ? a : b);
      var upperNote = positions.reduce((a, b) => a.dy < b.dy ? a : b);
      var defaultStemLength = NoteFlagPainter.defaultStemLength;
      flagPainter.drawFlags(
        notePosition: lowerNote,
        noteValue: division.noteValue,
        stemLength: lowerNote.dy - upperNote.dy + defaultStemLength,
      );
    }
  }
}
