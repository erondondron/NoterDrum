import 'dart:math';

import 'package:drums/models/drum_set.dart';
import 'package:drums/models/note.dart';
import 'package:drums/models/note_value.dart';
import 'package:drums/staff/configuration.dart';
import 'package:drums/staff/models.dart';
import 'package:drums/staff/note_value.dart';
import 'package:flutter/material.dart';

class NotePainter {
  final Color color;
  final Canvas canvas;

  const NotePainter({
    required this.canvas,
    required this.color,
  });

  Paint get paint => Paint()
    ..color = color
    ..strokeWidth = LinesWidthSettings.noteHead
    ..style = PaintingStyle.fill;

  void drawNoteHead(StaffNote note) {
    var position = note.position.toOffset();
    return switch (note.stroke) {
      StrokeType.opened => drawOpenedHead(position),
      StrokeType.bell => drawBellHead(position),
      StrokeType.choke => drawChokeHead(position),
      StrokeType.accent => drawAccentHead(note.drum, position),
      StrokeType.plain => drawPlainHead(note.drum, position),
      StrokeType.ghost => drawGhostNote(note.drum, position),
      StrokeType.rimClick => drawCrossHead(position),
      StrokeType.rimShot => drawRimShotHead(position),
      StrokeType.flam => drawFlamHead(note.drum, position),
      StrokeType.foot => drawCrossHead(position),
      _ => null,
    };
  }

  void drawPlainHead(Drum drum, Offset position) {
    <Drum>{Drum.hiHat, Drum.crash, Drum.ride}.contains(drum)
        ? drawCrossHead(position)
        : drawCircleHead(position);
  }

  void drawCircleHead(Offset position) {
    canvas.drawCircle(position, NotesSettings.headRadius, paint);
  }

  void drawAccentHead(Drum drum, Offset position) {
    drawPlainHead(drum, position);
    var path = Path()
      ..moveTo(
        position.dx - NotesSettings.headRadius,
        3.5 * FiveLinesSettings.gap,
      )
      ..lineTo(
        position.dx + NotesSettings.headRadius,
        3.75 * FiveLinesSettings.gap,
      )
      ..lineTo(
        position.dx - NotesSettings.headRadius,
        4 * FiveLinesSettings.gap,
      );
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void drawGhostNote(Drum drum, Offset position) {
    drawPlainHead(drum, position);
    var ghostRadius = 2 * NotesSettings.headRadius;
    var rect = Rect.fromCircle(center: position, radius: ghostRadius);
    var ghostPaint = paint..style = PaintingStyle.stroke;
    canvas.drawArc(rect, -pi / 4, pi / 2, false, ghostPaint);
    canvas.drawArc(rect, pi * 3 / 4, pi / 2, false, ghostPaint);
  }

  void drawRimShotHead(Offset position) {
    drawCircleHead(position);
    var offsetValue = 1.5 * NotesSettings.headRadius;
    var offset = Offset(offsetValue, offsetValue);
    canvas.drawLine(position - offset, position + offset, paint);
  }

  void drawFlamHead(Drum drum, Offset position) {
    drawPlainHead(drum, position);
    var offset = 3 * NotesSettings.headRadius;

    canvas
      ..save()
      ..translate(position.dx - offset, position.dy)
      ..scale(0.65);

    drawPlainHead(drum, Offset(0, 0));

    var stemLength = 3 * FiveLinesSettings.gap;
    var stemStart = StaffPoint(x: NotesSettings.headRadius);
    var stemEnd = StaffPoint(
      x: NotesSettings.headRadius + stemLength * NotesSettings.stemInclineDx,
      y: -stemLength,
    );

    var noteValuePainter = NoteValuePainter(color: color, canvas: canvas);
    noteValuePainter.drawStem(stemStart, stemEnd);
    noteValuePainter.drawSingleNoteFlag(stemEnd, NoteValue.eighth);

    var strokeLineStart = Offset(0, -stemLength + offset);
    var strokeLineEnd = Offset(offset, -stemLength + NotesSettings.headRadius);
    canvas
      ..drawLine(strokeLineStart, strokeLineEnd, paint)
      ..restore();
  }

  void drawCrossHead(Offset position) {
    var crossHeadRadius = 0.7 * NotesSettings.headRadius;
    var path = Path()
      ..moveTo(position.dx - crossHeadRadius, position.dy - crossHeadRadius)
      ..lineTo(position.dx + crossHeadRadius, position.dy + crossHeadRadius)
      ..moveTo(position.dx - crossHeadRadius, position.dy + crossHeadRadius)
      ..lineTo(position.dx + crossHeadRadius, position.dy - crossHeadRadius);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void drawBellHead(Offset position) {
    var path = Path()
      ..moveTo(position.dx - NotesSettings.headRadius, position.dy)
      ..lineTo(position.dx, position.dy + NotesSettings.headRadius)
      ..lineTo(position.dx + NotesSettings.headRadius, position.dy)
      ..lineTo(position.dx, position.dy - NotesSettings.headRadius)
      ..close();
    canvas.drawPath(path, paint);
  }

  void drawOpenedHead(Offset position) {
    drawCrossHead(position);
    var circlePaint = paint..style = PaintingStyle.stroke;
    canvas.drawCircle(position, NotesSettings.headRadius, circlePaint);
  }

  void drawChokeHead(Offset position) {
    drawCrossHead(position);
    canvas.drawCircle(
      Offset(position.dx, position.dy - FiveLinesSettings.gap),
      0.2 * FiveLinesSettings.gap,
      paint,
    );
  }
}
