import 'dart:math';

import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/flag.dart';
import 'package:drums/features/sheet_music/staff/lines.dart';
import 'package:flutter/material.dart';

class NotePainter {
  static const double linesGap = StaffPainter.linesGap;
  static const double linesWidth = 3 * StaffPainter.lineWidth;

  static const double stemInclineDegrees = 5;
  static const double stemIncline = 0.0875;
  static const double stemWidth = linesWidth;
  static const double stemOffset = headRadius - 0.5 * stemWidth;

  static const double headRadius = 0.5 * linesGap;
  static const double crossHeadRadius = 0.7 * headRadius;
  static const double chokeOffset = linesGap;
  static const double chokeRadius = 0.2 * linesGap;
  static const double accentStartPosition = 3.5 * linesGap;
  static const double accentStep = 0.25 * linesGap;
  static const double ghostRadius = 2 * headRadius;
  static const double rimShotLineOffset = 1.5 * headRadius;
  static const double flamSignOffset = headRadius * 3;
  static const double flamSignLength = linesGap * 3;
  static const double flamSignScale = 0.65;

  final Color color;
  final Canvas canvas;

  const NotePainter({
    required this.canvas,
    required this.color,
  });

  Paint get paint => Paint()
    ..color = color
    ..strokeWidth = linesWidth
    ..style = PaintingStyle.fill;

  static double getHeadStaffLinesPosition(Drum drum, StrokeType stroke) {
    var relative = switch (drum) {
      Drum.kick => 1.5,
      Drum.snare => -0.5,
      Drum.hiHat => stroke == StrokeType.foot ? 2.5 : -2.5,
      Drum.crash => -3,
      Drum.ride => -2,
      Drum.tom1 => -1.5,
      Drum.tom2 => -1,
      Drum.tom3 => 0.5,
    };
    return relative * linesGap;
  }

  void drawNoteHead(Offset position, Drum drum, StrokeType stroke) {
    return switch (stroke) {
      StrokeType.opened => drawOpenedHead(position),
      StrokeType.bell => drawBellHead(position),
      StrokeType.choke => drawChokeHead(position),
      StrokeType.accent => drawAccentHead(drum, position),
      StrokeType.plain => drawPlainHead(drum, position),
      StrokeType.ghost => drawGhostNote(drum, position),
      StrokeType.rimClick => drawCrossHead(position),
      StrokeType.rimShot => drawRimShotHead(position),
      StrokeType.flam => drawFlamHead(drum, position),
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
    canvas.drawCircle(position, headRadius, paint);
  }

  void drawAccentHead(Drum drum, Offset position) {
    drawPlainHead(drum, position);
    var path = Path()
      ..moveTo(position.dx - headRadius, accentStartPosition)
      ..lineTo(position.dx + headRadius, accentStartPosition + accentStep)
      ..lineTo(position.dx - headRadius, accentStartPosition + 2 * accentStep);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void drawGhostNote(Drum drum, Offset position) {
    drawPlainHead(drum, position);
    var rect = Rect.fromCircle(center: position, radius: ghostRadius);
    var ghostPaint = paint..style = PaintingStyle.stroke;
    canvas.drawArc(rect, -pi / 4, pi / 2, false, ghostPaint);
    canvas.drawArc(rect, pi * 3 / 4, pi / 2, false, ghostPaint);
  }

  void drawRimShotHead(Offset position) {
    drawCircleHead(position);
    var offset = Offset(rimShotLineOffset, rimShotLineOffset);
    canvas.drawLine(position - offset, position + offset, paint);
  }

  void drawFlamHead(Drum drum, Offset position) {
    drawPlainHead(drum, position);

    canvas
      ..save()
      ..translate(position.dx - flamSignOffset, position.dy)
      ..scale(flamSignScale);

    var signPosition = Offset(0, 0);
    drawCircleHead(signPosition);

    var flagPainter = NoteFlagPainter(color: color, canvas: canvas);
    flagPainter.drawFlags(
      notePosition: signPosition,
      noteValue: NoteValue.eighth,
      stemLength: flamSignLength,
    );

    var strokeLineStart = Offset(0, -flamSignLength + flamSignOffset);
    var strokeLineEnd = Offset(flamSignOffset, -flamSignLength + headRadius);
    canvas
      ..drawLine(strokeLineStart, strokeLineEnd, paint)
      ..restore();
  }

  void drawCrossHead(Offset position) {
    var path = Path()
      ..moveTo(position.dx - crossHeadRadius, position.dy - crossHeadRadius)
      ..lineTo(position.dx + crossHeadRadius, position.dy + crossHeadRadius)
      ..moveTo(position.dx - crossHeadRadius, position.dy + crossHeadRadius)
      ..lineTo(position.dx + crossHeadRadius, position.dy - crossHeadRadius);
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void drawBellHead(Offset position) {
    var path = Path()
      ..moveTo(position.dx - headRadius, position.dy)
      ..lineTo(position.dx, position.dy + headRadius)
      ..lineTo(position.dx + headRadius, position.dy)
      ..lineTo(position.dx, position.dy - headRadius)
      ..close();
    canvas.drawPath(path, paint);
  }

  void drawOpenedHead(Offset position) {
    drawCrossHead(position);
    var circlePaint = paint..style = PaintingStyle.stroke;
    canvas.drawCircle(position, headRadius, circlePaint);
  }

  void drawChokeHead(Offset position) {
    drawCrossHead(position);
    var pointPosition = Offset(position.dx, position.dy - chokeOffset);
    canvas.drawCircle(pointPosition, chokeRadius, paint);
  }
}
