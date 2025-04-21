import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/staff/beat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StaffWidget extends StatelessWidget {
  const StaffWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var staffColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Consumer<GrooveMeasure>(
        builder: (BuildContext context, GrooveMeasure measure, _) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              CustomPaint(
                size: Size(double.infinity, StaffPainter.height),
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
  static const double barLineWidth = 1;
  static const double lineWidth = 0.5;
  static const double linesGap = 10;
  static const int linesNumber = 5;

  static const double linesGapHalf = linesGap / 2;
  static const double heightHalf = linesNumber * linesGap;
  static const double height = heightHalf * 2;

  StaffPainter({required this.color});

  final Color color;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth;

    for (int i = 1; i <= linesNumber; i++) {
      var y = height - i * linesGap;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    paint.strokeWidth = barLineWidth;
    var start = height - linesGap;
    canvas.drawLine(Offset(0, start), Offset(0, heightHalf), paint);
    canvas.drawLine(
      Offset(size.width, start),
      Offset(size.width, heightHalf),
      paint,
    );
  }
}
