import 'package:drums/features/sheet_music/note/models.dart';
import 'package:drums/features/sheet_music/staff/lines.dart';
import 'package:flutter/material.dart';

class RestPainter {
  static const double linesWidth = StaffPainter.lineWidth * 4;
  static const double restHeadRadius = StaffPainter.linesGapHalf / 2;
  static const double restHeadOffset = StaffPainter.linesGapHalf;

  final Color color;
  final Canvas canvas;

  const RestPainter(
    this.canvas,
    this.color,
  );

  void drawRestSign(double xPosition, NoteValue noteValue) {
    noteValue == NoteValue.quarter
        ? drawQuarterRestSign(xPosition)
        : drawDivisionsRestSign(xPosition, noteValue);
  }

  void drawQuarterRestSign(double x) {
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

    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(sign, paint);
  }

  void drawDivisionsRestSign(double x, NoteValue noteValue) {
    var lineGapXOffset = StaffPainter.linesGap / 3.75;

    var topX = x + lineGapXOffset;
    var topY = StaffPainter.height - StaffPainter.linesGapHalf * 7;

    var bottomX = x;
    var bottomY = StaffPainter.height - StaffPainter.linesGap * 2;

    var restHeads = [Offset(topX - restHeadRadius * 2, topY)];

    if (noteValue.part > NoteValue.eighth.part) {
      bottomX -= lineGapXOffset;
      bottomY += StaffPainter.linesGap;
      var headPosition = Offset(
        topX - restHeadOffset - lineGapXOffset,
        topY + StaffPainter.linesGap,
      );
      restHeads.insert(0, headPosition);
    }

    if (noteValue.part > NoteValue.sixteenth.part) {
      topX += lineGapXOffset;
      topY -= StaffPainter.linesGap;
      restHeads.add(Offset(topX - restHeadOffset, topY));
    }

    var path = Path()
      ..moveTo(bottomX, bottomY)
      ..lineTo(topX, topY)
      ..lineTo(topX - restHeadOffset, topY);

    for (var headIdx = 0; headIdx < restHeads.length - 1; headIdx++) {
      var head = restHeads[headIdx];
      path
        ..moveTo(head.dx, head.dy)
        ..lineTo(head.dx + restHeadOffset, head.dy);
    }

    var paint = Paint()
      ..color = color
      ..strokeWidth = linesWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
    for (var head in restHeads) {
      paint = paint..style = PaintingStyle.fill;
      canvas.drawCircle(head, restHeadRadius, paint);
    }
  }
}
