import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/measure_unit/model.dart';
import 'package:drums/features/sheet_music/measure_unit/widget.dart';
import 'package:drums/features/sheet_music/note/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StaffWidget extends StatelessWidget {
  const StaffWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var staffColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.only(top: 25, bottom: 10),
      child: Consumer<SheetMusicMeasure>(
        builder: (BuildContext context, SheetMusicMeasure measure, _) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              CustomPaint(
                size: Size(double.infinity, 40),
                painter: StaffPainter(color: staffColor),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: measure.units
                    .map(
                      (unit) => ChangeNotifierProvider.value(
                        value: unit,
                        child: MeasureUnitStaffWidget(),
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

class MeasureUnitStaffWidget extends StatelessWidget {
  const MeasureUnitStaffWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var staffColor = Theme.of(context).colorScheme.onSurface;
    var padding = MeasureUnitWidget.padding * 2;
    return Consumer<MeasureUnit>(
      builder: (BuildContext context, MeasureUnit unit, _) {
        return CustomPaint(
          size: Size(unit.width + padding, 40),
          painter: MeasureUnitPainter(unit: unit, color: staffColor),
        );
      },
    );
  }
}

class StaffPainter extends CustomPainter {
  static const double barLineWidth = 1;
  static const double lineWidth = 0.5;
  static const double linesGap = 10;
  static const int linesNumber = 5;

  StaffPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth;

    for (int i = 0; i < linesNumber; i++) {
      var y = i * linesGap;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    paint.strokeWidth = barLineWidth;
    var height = (linesNumber - 1) * linesGap;
    canvas.drawLine(Offset(0, 0), Offset(0, height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MeasureUnitPainter extends CustomPainter {
  static const double noteRadius = 5;

  final MeasureUnit unit;
  final Color color;

  MeasureUnitPainter({
    required this.unit,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var isEmpty = true;
    for (var drumLine in unit.drumLines){
      for (var note in drumLine.notes){
        if (note.type != StrokeType.off){
          isEmpty = false;
        }
      }
    }
    if (isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var position = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(position, noteRadius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
