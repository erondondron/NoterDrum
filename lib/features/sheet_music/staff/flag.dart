import 'dart:math';

import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/note.dart';
import 'package:flutter/material.dart';

class NoteFlagPainter {
  static const double flagWidth = NotePainter.linesGap;
  static const double defaultStemLength = 4 * NotePainter.linesGap;

  final Color color;
  final Canvas canvas;

  const NoteFlagPainter({
    required this.canvas,
    required this.color,
  });

  Paint get paint => Paint()
    ..color = color
    ..strokeWidth = NotePainter.stemWidth
    ..style = PaintingStyle.fill;

  void drawFlags({
    required Offset notePosition,
    required NoteValue noteValue,
    double stemLength = defaultStemLength,
  }) {
    if (noteValue.part < NoteValue.quarter.part) return;
    var stemStart = Offset(
      notePosition.dx + NotePainter.stemOffset,
      notePosition.dy,
    );
    var stemEnd = Offset(
      stemStart.dx + stemLength * NotePainter.stemIncline,
      notePosition.dy - stemLength,
    );
    canvas.drawLine(stemStart, stemEnd, paint);

    var flagsCount = 0;
    var flagValuePart = NoteValue.eighth.part;
    while (noteValue.part >= flagValuePart) {
      var offset = flagWidth * flagsCount++;
      var position = Offset(
        stemEnd.dx - offset * NotePainter.stemIncline,
        stemEnd.dy + offset,
      );
      _drawFlag(position);
      flagValuePart *= 2;
    }
  }

  void _drawFlag(Offset position) {
    var path = Path()
      ..cubicTo(0, 1, 1.5, 1.25, 0.5, 2.6)
      ..cubicTo(1, 1.5, 0.4, 1, 0, 1);

    canvas
      ..save()
      ..translate(position.dx, position.dy)
      ..rotate(NotePainter.stemInclineDegrees * pi / 180)
      ..scale(flagWidth)
      ..drawPath(path, paint)
      ..restore();
  }
}
