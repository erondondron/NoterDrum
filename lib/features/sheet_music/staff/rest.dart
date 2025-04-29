import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/lines.dart';
import 'package:flutter/material.dart';

class RestPainter {
  static const double linesWidth = StaffPainter.lineWidth;
  static const double linesGap = StaffPainter.linesGap;

  static const double quarterRestPosition = -1.5 * linesGap;
  static const double quarterRestScale = 0.5 * linesGap;

  static const double divRestScale = linesGap;
  static const double divRestStemWidth = 4 * linesWidth / divRestScale;
  static const double divRestStemIncline = 0.27;
  static const double divRestHeadRadius = 0.25;
  static const double divRestHeadOffset = 0.5;

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
      ..cubicTo(3.9, 3.2, -1.6, 1.3, 1.4, 4.7)
      ..cubicTo(-0.2, 4.1, -0.3, 4.7, 0, 5.9)
      ..cubicTo(-0.9, 4.7, -1.7, 2.7, 1.4, 4.7)
      ..cubicTo(-3.2, 0.7, 1.9, 3.3, 0, 0);

    canvas
      ..save()
      ..translate(x, quarterRestPosition)
      ..scale(quarterRestScale)
      ..drawPath(sign, paint)
      ..restore();
  }

  void drawDivisionsRestSign(double x, NoteValue noteValue) {
    var topX = divRestStemIncline;
    var topY = -0.5;

    var bottomX = 0.0;
    var bottomY = 1.0;

    var restHeads = [Offset(topX - divRestHeadOffset, topY)];

    if (noteValue.part > NoteValue.eighth.part) {
      bottomX -= divRestStemIncline;
      bottomY += 1;
      restHeads.insert(0, Offset(-divRestHeadOffset, topY + 1));
    }

    if (noteValue.part > NoteValue.sixteenth.part) {
      topX += divRestStemIncline;
      topY -= 1;
      restHeads.add(Offset(topX - divRestHeadOffset, topY));
    }

    var path = Path()
      ..moveTo(bottomX, bottomY)
      ..lineTo(topX, topY)
      ..lineTo(topX - divRestHeadOffset, topY);

    for (var headIdx = 0; headIdx < restHeads.length - 1; headIdx++) {
      var head = restHeads[headIdx];
      path
        ..moveTo(head.dx, head.dy)
        ..lineTo(head.dx + divRestHeadOffset, head.dy);
    }

    canvas
      ..save()
      ..translate(x, 0)
      ..scale(divRestScale);

    var restPaint = paint;
    for (var head in restHeads) {
      canvas.drawCircle(head, divRestHeadRadius, restPaint);
    }

    restPaint = restPaint
      ..strokeWidth = divRestStemWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, restPaint);
    canvas.restore();
  }
}
