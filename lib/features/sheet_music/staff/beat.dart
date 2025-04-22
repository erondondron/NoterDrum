import 'package:drums/features/sheet_music/beat/models.dart';
import 'package:drums/features/sheet_music/beat/widget.dart';
import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/five_lines.dart';
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
  static const double headRadius = 5;
  static const double stemWidth = 1;
  static const double flagWidth = 10;

  static const double stemOffset = headRadius - stemWidth / 2;

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
    final paint = Paint()
      ..color = color
      ..strokeWidth = stemWidth
      ..style = PaintingStyle.fill;

    for (var division in beat.divisions) {
      var positions = getNotePositions(division);
      if (positions.isEmpty) {
        var position = Offset(division.position, StaffPainter.height - 30);
        canvas.drawCircle(position, headRadius * 2, paint);
        continue;
      }

      for (var position in positions) {
        canvas.drawCircle(position, headRadius, paint);
      }
      var stemX = division.position + stemOffset;
      var lowerNote = positions.reduce((a, b) => a.dy > b.dy ? a : b);
      canvas.drawLine(Offset(stemX, 0), Offset(stemX, lowerNote.dy), paint);

      var flagsCount = 0;
      var flagValuePart = NoteValue.eighth.part;
      while (division.noteValue.part >= flagValuePart) {
        var start = Offset(stemX, flagWidth * flagsCount++);
        var flag = getSingleNoteFlag(start);
        canvas.drawPath(flag, paint);
        flagValuePart *= 2;
      }
    }
  }

  List<Offset> getNotePositions(BeatDivision division) {
    var positions = division.notes.values
        .whereType<SingleNote>()
        .where((note) => note.stroke != StrokeType.off)
        .map((note) => Offset(
              division.position,
              getNoteStaffYPosition(note, note.beatLine.drum),
            ))
        .toList()
      ..sort((a, b) => a.dy.compareTo(b.dy));

    var previous = 0.0;
    var offset = false;
    for (var i = 0; i < positions.length; i++) {
      var position = positions[i];
      var isNear = position.dy - previous < StaffPainter.linesGap;
      previous = position.dy;
      offset = isNear ? !offset : false;
      if (offset) {
        positions[i] = Offset(
          offset ? position.dx + 2 * stemOffset : position.dx,
          position.dy,
        );
      }
    }
    return positions;
  }

  double getNoteStaffYPosition(SingleNote note, Drum drum) {
    var position = switch (drum) {
      Drum.kick => StaffPainter.linesGapHalf * 3,
      Drum.snare => StaffPainter.linesGapHalf * 7,
      Drum.hiHat => note.stroke == StrokeType.foot
          ? StaffPainter.linesGapHalf
          : StaffPainter.linesGapHalf * 11,
      Drum.crash => StaffPainter.linesGapHalf * 12,
      Drum.ride => StaffPainter.linesGapHalf * 10,
      Drum.tom1 => StaffPainter.linesGapHalf * 9,
      Drum.tom2 => StaffPainter.linesGapHalf * 8,
      Drum.tom3 => StaffPainter.linesGapHalf * 5,
    };
    return StaffPainter.height - position;
  }

  Path getSingleNoteFlag(Offset stemTop) {
    return Path()
      ..moveTo(stemTop.dx, stemTop.dy)
      ..cubicTo(
        stemTop.dx,
        stemTop.dy + flagWidth,
        stemTop.dx + flagWidth * 1.5,
        stemTop.dy + flagWidth * 1.25,
        stemTop.dx + flagWidth * 0.5,
        stemTop.dy + flagWidth * 2.6,
      )
      ..cubicTo(
        stemTop.dx + flagWidth,
        stemTop.dy + flagWidth * 1.5,
        stemTop.dx + flagWidth * 0.4,
        stemTop.dy + flagWidth,
        stemTop.dx,
        stemTop.dy + flagWidth,
      );
  }
}
