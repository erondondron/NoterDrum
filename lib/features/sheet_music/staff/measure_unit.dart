import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/measure_unit/model.dart';
import 'package:drums/features/sheet_music/measure_unit/widget.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:drums/features/sheet_music/staff/five_lines.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeasureUnitStaffWidget extends StatelessWidget {
  const MeasureUnitStaffWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var staffColor = Theme.of(context).colorScheme.onSurface;
    var padding = MeasureUnitWidget.padding * 2;
    return Consumer<MeasureUnit>(
      builder: (BuildContext context, MeasureUnit unit, _) {
        return CustomPaint(
          size: Size(unit.width + padding, StaffPainter.height),
          painter: MeasureUnitPainter(unit: unit, color: staffColor),
        );
      },
    );
  }
}

class MeasureUnitPainter extends CustomPainter {
  static const double headRadius = 5;
  static const double stemWidth = 1;

  static const double stemOffset = headRadius - stemWidth / 2;

  final MeasureUnit unit;
  final Color color;

  MeasureUnitPainter({
    required this.unit,
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

    var notePositions = getNotePositions();
    for (var group in notePositions.entries) {
      var prevYPosition = 0.0;
      var xOffset = false;
      for (var position in group.value) {
        xOffset = position.dy - prevYPosition < StaffPainter.linesGap
            ? !xOffset
            : false;

        var notePosition = Offset(
          xOffset ? position.dx + 2 * stemOffset : position.dx,
          position.dy,
        );
        canvas.drawCircle(notePosition, headRadius, paint);
        prevYPosition = position.dy;
      }

      var stemX = group.key + stemOffset;
      var lowerNote = group.value.reduce((a, b) => a.dy > b.dy ? a : b);
      canvas.drawLine(Offset(stemX, 0), Offset(stemX, lowerNote.dy), paint);
    }
  }

  Map<double, List<Offset>> getNotePositions() {
    var notePositions = <Offset>[];
    for (var drumLine in unit.drumLines) {
      var lineOffset = MeasureUnitWidget.padding;
      for (var note in drumLine.notes) {
        if (note.type == StrokeType.off) {
          lineOffset += note.width;
          continue;
        }
        var x = Note.minWidth / 2;
        var y = getNoteStaffYPosition(note, drumLine.drum);
        var position = Offset(lineOffset + x, StaffPainter.height - y);
        lineOffset += note.width;
        notePositions.add(position);
      }
    }

    var groups = <double, List<Offset>>{};
    for (var position in notePositions) {
      var group = groups.entries.firstWhere(
        (entry) => (position.dx - entry.key).abs() < 1e-5,
        orElse: () {
          groups[position.dx] = [];
          return MapEntry(position.dx, groups[position.dx]!);
        },
      );
      group.value.add(position);
    }

    for (var group in groups.values) {
      group.sort((a, b) => a.dy.compareTo(b.dy));
    }
    return groups;
  }

  double getNoteStaffYPosition(Note note, Drum drum) {
    return switch (drum) {
      Drum.kick => StaffPainter.linesGapHalf * 3,
      Drum.snare => StaffPainter.linesGapHalf * 7,
      Drum.hiHat => note.type == StrokeType.foot
          ? StaffPainter.linesGapHalf
          : StaffPainter.linesGapHalf * 11,
      Drum.crash => StaffPainter.linesGapHalf * 12,
      Drum.ride => StaffPainter.linesGapHalf * 10,
      Drum.tom1 => StaffPainter.linesGapHalf * 9,
      Drum.tom2 => StaffPainter.linesGapHalf * 8,
      Drum.tom3 => StaffPainter.linesGapHalf * 5,
    };
  }
}
