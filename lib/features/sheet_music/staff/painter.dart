import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StaffWidget extends StatelessWidget {
  const StaffWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var staffColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.only(top: 25),
      child: Consumer<SheetMusicMeasure>(
        builder: (BuildContext context, SheetMusicMeasure measure, _) {
          return CustomPaint(
            size: Size(double.infinity, 50),
            painter: StaffPainter(color: staffColor),
          );
        },
      ),
    );
  }
}

class StaffPainter extends CustomPainter {
  StaffPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 10.0;
    for (int i = 0; i < 5; i++) {
      final y = i * spacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    paint.strokeWidth = 1;
    canvas.drawLine(Offset(0, 0), Offset(0, 40), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, 40), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
