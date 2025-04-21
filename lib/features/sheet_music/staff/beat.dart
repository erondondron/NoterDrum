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
      var positions = division.notes.values
          .whereType<SingleNote>()
          .where((note) => note.stroke != StrokeType.off)
          .map((note) => Offset(
                division.position,
                getNoteStaffYPosition(note, note.beatLine.drum),
              ))
          .toList()
        ..sort((a, b) => a.dy.compareTo(b.dy));

      var previousY = 0.0;
      var dx = false;
      for (var position in positions) {
        dx = position.dy - previousY < StaffPainter.linesGap ? !dx : false;
        var notePosition = Offset(
          dx ? position.dx + 2 * stemOffset : position.dx,
          position.dy,
        );
        canvas.drawCircle(notePosition, headRadius, paint);
        previousY = position.dy;

        var stemX = division.position + stemOffset;
        var lowerNote = positions.reduce((a, b) => a.dy > b.dy ? a : b);
        canvas.drawLine(Offset(stemX, 0), Offset(stemX, lowerNote.dy), paint);
      }
    }
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
}
