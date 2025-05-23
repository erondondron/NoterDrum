import 'package:drums/features/models/note.dart';
import 'package:drums/features/staff/configuration.dart';
import 'package:flutter/material.dart';

class RestPainter {
  final Color color;
  final Canvas canvas;

  const RestPainter({
    required this.color,
    required this.canvas,
  });

  Paint get paint => Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  void drawRestSign(double x, NoteValue noteValue) {
    noteValue == NoteValue.quarter
        ? drawQuarterRestSign(x)
        : drawDivisionsRestSign(x, noteValue);
  }

  void drawQuarterRestSign(double x) {
    var sign = Path()
      ..cubicTo(19.5, 16.0, -8.0, 6.5, 7.0, 23.5)
      ..cubicTo(-1.0, 20.5, -1.5, 23.5, 0.0, 29.5)
      ..cubicTo(-4.5, 23.5, -8.5, 13.5, 7.0, 23.5)
      ..cubicTo(-16.0, 3.5, 9.5, 16.5, 0.0, 0.0);

    canvas
      ..save()
      ..translate(x, -1.5 * FiveLinesSettings.gap)
      ..drawPath(sign, paint)
      ..restore();
  }

  void drawDivisionsRestSign(double x, NoteValue noteValue) {
    var stemIncline = 0.27;
    var headOffset = 0.5;

    var topX = stemIncline;
    var topY = -0.5;

    var bottomX = 0.0;
    var bottomY = 1.0;

    var restHeads = [Offset(topX - headOffset, topY)];

    if (noteValue.part > NoteValue.eighth.part) {
      bottomX -= stemIncline;
      bottomY += 1;
      restHeads.insert(0, Offset(-headOffset, topY + 1));
    }

    if (noteValue.part > NoteValue.sixteenth.part) {
      topX += stemIncline;
      topY -= 1;
      restHeads.add(Offset(topX - headOffset, topY));
    }

    var path = Path()
      ..moveTo(bottomX, bottomY)
      ..lineTo(topX, topY)
      ..lineTo(topX - headOffset, topY);

    for (var headIdx = 0; headIdx < restHeads.length - 1; headIdx++) {
      var head = restHeads[headIdx];
      path
        ..moveTo(head.dx, head.dy)
        ..lineTo(head.dx + headOffset, head.dy);
    }

    canvas
      ..save()
      ..translate(x, 0)
      ..scale(FiveLinesSettings.gap);

    var restPaint = paint;
    for (var head in restHeads) {
      canvas.drawCircle(head, 0.25, restPaint);
    }

    restPaint = restPaint
      ..strokeWidth = 2 / FiveLinesSettings.gap
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, restPaint);
    canvas.restore();
  }
}
