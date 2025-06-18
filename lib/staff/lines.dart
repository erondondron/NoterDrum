import 'package:drums/models/measure.dart';
import 'package:drums/staff/beat.dart';
import 'package:drums/staff/configuration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StaffWidget extends StatelessWidget {
  const StaffWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var staffColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Consumer<GrooveMeasure>(
        builder: (BuildContext context, GrooveMeasure measure, _) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              CustomPaint(
                size: Size(double.infinity, FiveLinesSettings.height),
                painter: StaffPainter(color: staffColor),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: measure.beats
                    .map(
                      (beat) => ChangeNotifierProvider.value(
                        value: beat,
                        child: BeatStaffWidget(),
                      ),
                    )
                    .toList(),
              )
            ],
          );
        },
      ),
    );
  }
}

class StaffPainter extends CustomPainter {
  final Color color;

  StaffPainter({required this.color});

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = LinesWidthSettings.base;

    for (int i = 0; i < FiveLinesSettings.number; i++) {
      var y = FiveLinesSettings.bottom - i * FiveLinesSettings.gap;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    paint.strokeWidth = LinesWidthSettings.bar;
    canvas.drawLine(
      Offset(0, FiveLinesSettings.top),
      Offset(0, FiveLinesSettings.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, FiveLinesSettings.top),
      Offset(size.width, FiveLinesSettings.bottom),
      paint,
    );
  }
}
