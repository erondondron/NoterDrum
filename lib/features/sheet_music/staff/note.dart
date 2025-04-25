import 'dart:math';

import 'package:drums/features/sheet_music/drum_set/model.dart';
import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/flag.dart';
import 'package:drums/features/sheet_music/staff/lines.dart';
import 'package:flutter/material.dart';

class NotePainter {
  static const linesWidth = StaffPainter.lineWidth * 3;
  static const double headRadius = StaffPainter.linesGapHalf;

  final Color color;
  final Canvas canvas;

  const NotePainter(
    this.canvas,
    this.color,
  );

  Paint get paint => Paint()
    ..color = color
    ..strokeWidth = linesWidth
    ..style = PaintingStyle.fill;

  static double getHeadYPosition(Drum drum, StrokeType stroke) {
    return switch (drum) {
      Drum.kick => StaffPainter.linesGapHalf * 3,
      Drum.snare => StaffPainter.linesGapHalf * 7,
      Drum.hiHat => stroke == StrokeType.foot
          ? StaffPainter.linesGapHalf
          : StaffPainter.linesGapHalf * 11,
      Drum.crash => StaffPainter.linesGapHalf * 12,
      Drum.ride => StaffPainter.linesGapHalf * 10,
      Drum.tom1 => StaffPainter.linesGapHalf * 9,
      Drum.tom2 => StaffPainter.linesGapHalf * 8,
      Drum.tom3 => StaffPainter.linesGapHalf * 5,
    };
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
      ..moveTo(
        position.dx - headRadius,
        StaffPainter.height + StaffPainter.linesGapHalf,
      )
      ..lineTo(
        position.dx + headRadius,
        StaffPainter.height + StaffPainter.linesGapHalf * 3 / 2,
      )
      ..lineTo(
        position.dx - headRadius,
        StaffPainter.height + StaffPainter.linesGap,
      );
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void drawGhostNote(Drum drum, Offset position) {
    drawPlainHead(drum, position);
    var rect = Rect.fromCircle(center: position, radius: headRadius * 2);
    var ghostPaint = paint..style = PaintingStyle.stroke;
    canvas.drawArc(rect, -pi / 4, pi / 2, false, ghostPaint);
    canvas.drawArc(rect, pi * 3 / 4, pi / 2, false, ghostPaint);
  }

  void drawRimShotHead(Offset position) {
    drawCircleHead(position);
    var offset = Offset(headRadius * 1.5, headRadius * 1.5);
    canvas.drawLine(position - offset, position + offset, paint);
  }

  void drawFlamHead(Drum drum, Offset position) {
    drawPlainHead(drum, position);

    var signPosition = Offset(position.dx - headRadius * 3, position.dy);
    var flamSignRadius = headRadius / 1.5;
    canvas.drawCircle(signPosition, flamSignRadius, paint);

    var stemXPosition = signPosition.dx + flamSignRadius - linesWidth / 2;
    var stemYEndPosition = signPosition.dy - StaffPainter.linesGap * 2;
    var stemBottom = Offset(stemXPosition, signPosition.dy);
    var stemTop = Offset(stemXPosition, stemYEndPosition);
    canvas.drawLine(stemBottom, stemTop, paint);

    var flagPainter = NoteFlagPainter(canvas, color);
    flagPainter.drawSingleNoteFlag(
      stemTop: stemTop,
      size: StaffPainter.linesGap / 1.5,
    );

    var strokeLineStart = Offset(
      stemTop.dx + headRadius,
      stemTop.dy + headRadius,
    );
    var strokeLineEnd = Offset(
      stemTop.dx - headRadius,
      stemTop.dy + headRadius * 2.5,
    );
    canvas.drawLine(strokeLineStart, strokeLineEnd, paint);
  }

  void drawCrossHead(Offset position) {
    var offset = headRadius * 0.7;
    var path = Path()
      ..moveTo(position.dx - offset, position.dy - offset)
      ..lineTo(position.dx + offset, position.dy + offset)
      ..moveTo(position.dx - offset, position.dy + offset)
      ..lineTo(position.dx + offset, position.dy - offset);
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
    var pointPosition = Offset(position.dx, position.dy - headRadius * 2);
    canvas.drawCircle(pointPosition, 2, paint);
  }
}
