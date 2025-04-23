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
  static const double headRadius = StaffPainter.linesGap / 2;
  static const double flagWidth = StaffPainter.linesGap;
  static const double stemWidth = 1;
  static const double beamWidth = 4;
  static const double singleBeamLength = StaffPainter.linesGap;

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
        drawRestSign(canvas, division.position, division.noteValue);
        continue;
      }
      for (var position in positions) {
        canvas.drawCircle(position, headRadius, paint);
      }
      var stemX = division.position + stemOffset;
      var lowerNote = positions.reduce((a, b) => a.dy > b.dy ? a : b);
      canvas.drawLine(Offset(stemX, 0), Offset(stemX, lowerNote.dy), paint);
    }
    drawNotesBeam(canvas, beat.divisions);
  }

  List<Offset> getNotePositions(BeatDivision division) {
    var positions = division.notes
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

  void drawNotesBeam(Canvas canvas, List<BeatDivision> divisions) {
    var eighthGroups = getBeamGroups(divisions, NoteValue.eighth);
    for (var group in eighthGroups) {
      group.length > 1
          ? drawBeamGroup(canvas, group, NoteValue.eighth)
          : drawSingleNoteFlags(canvas, group.first);
    }
  }

  List<List<BeatDivision>> getBeamGroups(
    List<BeatDivision> divisions,
    NoteValue noteValue,
  ) {
    var rawBeamGroups = <List<BeatDivision>>[];
    var beamGroup = <BeatDivision>[];
    for (var division in divisions) {
      if (division.noteValue.part >= noteValue.part) {
        beamGroup.add(division);
        continue;
      }
      if (beamGroup.isEmpty) continue;
      rawBeamGroups.add(beamGroup);
      beamGroup = [];
    }
    if (beamGroup.isNotEmpty) {
      rawBeamGroups.add(beamGroup);
    }

    var beamGroups = <List<BeatDivision>>[];
    for (var rawGroup in rawBeamGroups) {
      int startIdx = rawGroup.indexWhere((div) => div.notes.isNotEmpty);
      if (startIdx == -1) continue;

      int endIdx = rawGroup.lastIndexWhere((div) => div.notes.isNotEmpty);
      var group = rawGroup.sublist(startIdx, endIdx + 1);
      beamGroups.add(group);
    }
    return beamGroups;
  }

  void drawBeamGroup(
    Canvas canvas,
    List<BeatDivision> beamGroup,
    NoteValue noteValue,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = beamWidth
      ..style = PaintingStyle.fill;

    var relative = noteValue.part.bitLength - NoteValue.eighth.part.bitLength;
    var position = relative * StaffPainter.linesGap;
    var startOffset = stemOffset - stemWidth / 2;
    var endOffset = stemOffset + stemWidth / 2;
    var beamStart = Offset(beamGroup.first.position + startOffset, position);
    var beamEnd = Offset(beamGroup.last.position + endOffset, position);
    canvas.drawLine(beamStart, beamEnd, paint);

    if (noteValue == NoteValue.values.last) return;
    drawNextBeamGroups(canvas, beamGroup, noteValue);
  }

  void drawNextBeamGroups(
    Canvas canvas,
    List<BeatDivision> beamGroup,
    NoteValue noteValue,
  ) {
    var nextValue = NoteValue.values.firstWhere(
      (note) => note.part == noteValue.part * 2,
    );
    var nextGroups = <BeatDivision, List<BeatDivision>>{
      for (var group in getBeamGroups(beamGroup, nextValue)) group.first: group
    };
    var forwardDir = true;
    var divIdx = 0;
    while (divIdx < beamGroup.length) {
      var division = beamGroup[divIdx++];
      var group = nextGroups[division];
      if (group == null) {
        if (division.noteValue == nextValue) {
          forwardDir = !forwardDir;
        }
        continue;
      }
      if (group.length > 1) {
        drawBeamGroup(canvas, group, nextValue);
        divIdx += group.length - 1;
        continue;
      }
      if (divIdx == beamGroup.length) {
        forwardDir = false;
      }
      drawSingleNoteBeam(canvas, division.position, nextValue, forwardDir);
    }
  }

  void drawSingleNoteBeam(
    Canvas canvas,
    double position,
    NoteValue noteValue,
    bool forwardDirection,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = beamWidth
      ..style = PaintingStyle.fill;

    var yRelative = noteValue.part.bitLength - NoteValue.eighth.part.bitLength;
    var yAbsolute = yRelative * StaffPainter.linesGap;
    var xDirection = forwardDirection ? 1 : -1;
    var xStart = position + stemOffset - stemWidth / 2;
    var xEnd = xStart + singleBeamLength * xDirection;
    var beamStart = Offset(xStart, yAbsolute);
    var beamEnd = Offset(xEnd, yAbsolute);
    canvas.drawLine(beamStart, beamEnd, paint);
  }

  void drawSingleNoteFlags(Canvas canvas, BeatDivision division) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stemWidth
      ..style = PaintingStyle.fill;

    var flagsCount = 0;
    var flagValuePart = NoteValue.eighth.part;
    while (division.noteValue.part >= flagValuePart) {
      var position = Offset(
        division.position + stemOffset,
        flagWidth * flagsCount++,
      );
      var flag = getSingleNoteFlag(position);
      canvas.drawPath(flag, paint);
      flagValuePart *= 2;
    }
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

  void drawRestSign(Canvas canvas, double x, NoteValue noteValue) {
    noteValue == NoteValue.quarter
        ? drawQuarterRestSign(canvas, x)
        : drawDivisionsRestSign(canvas, x, noteValue);
  }

  void drawQuarterRestSign(Canvas canvas, double x) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    var point = Offset(x, StaffPainter.heightHalf + StaffPainter.linesGapHalf);
    var template = StaffPainter.linesGapHalf;
    var sign = Path()
      ..moveTo(point.dx, point.dy)
      ..cubicTo(
        point.dx + template * 3.9,
        point.dy + template * 3.2,
        point.dx - template * 1.6,
        point.dy + template * 1.3,
        point.dx + template * 1.4,
        point.dy + template * 4.7,
      )
      ..cubicTo(
        point.dx - template * 0.2,
        point.dy + template * 4.1,
        point.dx - template * 0.3,
        point.dy + template * 4.7,
        point.dx,
        point.dy + template * 5.9,
      )
      ..cubicTo(
        point.dx - template * 0.9,
        point.dy + template * 4.7,
        point.dx - template * 1.7,
        point.dy + template * 2.7,
        point.dx + template * 1.4,
        point.dy + template * 4.7,
      )
      ..cubicTo(
        point.dx - template * 3.2,
        point.dy + template * 0.7,
        point.dx + template * 1.9,
        point.dy + template * 3.3,
        point.dx,
        point.dy,
      );
    canvas.drawPath(sign, paint);
  }

  void drawDivisionsRestSign(Canvas canvas, double x, NoteValue noteValue) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = stemWidth * 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    var lineGapXOffset = StaffPainter.linesGap / 3.75;

    var topX = x + lineGapXOffset;
    var topY = StaffPainter.height - StaffPainter.linesGapHalf * 7;

    var bottomX = x;
    var bottomY = StaffPainter.height - StaffPainter.linesGap * 2;

    var restHeadRadius = headRadius / 2;
    var restHeads = [Offset(topX - headRadius, topY)];

    if (noteValue.part > NoteValue.eighth.part) {
      bottomX -= lineGapXOffset;
      bottomY += StaffPainter.linesGap;
      var headPosition = Offset(
        topX - headRadius - lineGapXOffset,
        topY + StaffPainter.linesGap,
      );
      restHeads.insert(0, headPosition);
    }

    if (noteValue.part > NoteValue.sixteenth.part) {
      topX += lineGapXOffset;
      topY -= StaffPainter.linesGap;
      restHeads.add(Offset(topX - headRadius, topY));
    }

    var path = Path()
      ..moveTo(bottomX, bottomY)
      ..lineTo(topX, topY)
      ..lineTo(topX - headRadius, topY);

    for (var headIdx = 0; headIdx < restHeads.length - 1; headIdx++) {
      var head = restHeads[headIdx];
      path
        ..moveTo(head.dx, head.dy)
        ..lineTo(head.dx + headRadius, head.dy);
    }

    canvas.drawPath(path, paint);
    for (var head in restHeads) {
      paint = paint..style = PaintingStyle.fill;
      canvas.drawCircle(head, restHeadRadius, paint);
    }
  }
}
