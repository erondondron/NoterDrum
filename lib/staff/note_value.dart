import 'package:drums/models/note_value.dart';
import 'package:drums/staff/configuration.dart';
import 'package:drums/staff/models.dart';
import 'package:flutter/material.dart';

class NoteValuePainter {
  final Color color;
  final Canvas canvas;

  const NoteValuePainter({
    required this.canvas,
    required this.color,
  });

  Paint get paint => Paint()
    ..color = color
    ..strokeWidth = LinesWidthSettings.stem
    ..style = PaintingStyle.fill;

  void drawStem(StaffPoint start, StaffPoint end) {
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
  }

  void drawSingleNoteFlag(StaffPoint position, NoteValue noteValue) {
    if (noteValue.part < NoteValue.quarter.part) return;
    var count = noteValue.part.bitLength - NoteValue.quarter.part.bitLength;
    for (var i = 0; i < count; i++) {
      var offset = NotesSettings.flagWidth * i;
      var startPosition = Offset(
        position.x - offset * NotesSettings.stemInclineDx,
        position.y + offset,
      );

      var path = Path()
        ..cubicTo(0, 1, 1.5, 1.25, 0.5, 2.6)
        ..cubicTo(1, 1.5, 0.4, 1, 0, 1);

      canvas
        ..save()
        ..translate(startPosition.dx, startPosition.dy)
        ..rotate(NotesSettings.stemInclineAngle)
        ..scale(NotesSettings.flagWidth)
        ..drawPath(path, paint)
        ..restore();
    }
  }

  void drawBeam({required StaffNoteGroup group, int beamLevel = 0}) {
    if (group.noteValue.part < NoteValue.eighth.part) return;

    var startStack = group.stacks.first;
    var endStack = group.stacks.last;
    if (startStack.stemEnd == null) return;

    _drawBeamLine(
      position: startStack.stemEnd!,
      beamLevel: beamLevel,
      length: endStack.x - startStack.x,
      inclineDx: group.beamInclineDx,
    );

    if (group.noteValue.length == 3 && beamLevel == 0) {
      _drawTripletSign(group);
    }

    for (var division in group.singleNotes) {
      if (division.stemEnd == null) continue;
      var singleBeamCount =
          division.noteValue.part.bitLength - group.noteValue.part.bitLength;
      for (var i = 1; i <= singleBeamCount; i++) {
        _drawBeamLine(
          position: division.stemEnd!,
          beamLevel: beamLevel + i,
          inclineDx: group.beamInclineDx,
          rightFlag: division.rightFlag,
        );
      }
    }

    for (var subgroup in group.subgroups.values) {
      drawBeam(group: subgroup, beamLevel: beamLevel + 1);
    }
  }

  void _drawBeamLine({
    required StaffPoint position,
    int beamLevel = 0,
    double length = NotesSettings.flagWidth,
    double inclineDx = NotesSettings.beamInclineDx,
    bool rightFlag = true,
  }) {
    var topYOffset = beamLevel * FiveLinesSettings.gap;
    var topXOffset = topYOffset * NotesSettings.stemInclineDx;
    var topLeft = Offset(
      position.x - topXOffset,
      position.y + topYOffset,
    );

    var bottomYOffset = topYOffset + NotesSettings.beamThickness;
    var bottomXOffset = bottomYOffset * NotesSettings.stemInclineDx;
    var bottomLeft = Offset(
      position.x - bottomXOffset,
      position.y + bottomYOffset,
    );

    length *= rightFlag ? 1 : -1;
    var beamIncline = length * inclineDx;
    length += beamIncline * NotesSettings.stemInclineDx;
    var topRight = Offset(
      topLeft.dx + length,
      topLeft.dy - beamIncline,
    );
    var bottomRight = Offset(
      bottomLeft.dx + length,
      bottomLeft.dy - beamIncline,
    );

    var path = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawTripletSign(StaffNoteGroup group) {
    var startStack = group.stacks.first;
    var endStack = group.stacks.last;
    var signFont = NotesSettings.tripletSignFont;
    var position = Offset(
      (startStack.stemEnd!.x + endStack.stemEnd!.x - signFont / 2) / 2,
      (startStack.stemEnd!.y + endStack.stemEnd!.y - 2.5 * signFont) / 2,
    );
    var textStyle = TextStyle(
      color: color,
      fontSize: NotesSettings.tripletSignFont,
      fontWeight: FontWeight.bold,
    );
    var textSpan = TextSpan(text: "3", style: textStyle);
    var textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: endStack.stemEnd!.x - startStack.stemEnd!.x,
    );
    textPainter.paint(canvas, position);
  }
}
