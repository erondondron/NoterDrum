import 'package:drums/features/sheet_music/measure_unit/model.dart';
import 'package:drums/features/sheet_music/measure_unit_line/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeasureUnitWidget extends StatelessWidget {
  static const double padding = 13;

  const MeasureUnitWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MeasureUnit>(
      builder: (BuildContext context, MeasureUnit unit, _) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            key: unit.key,
            children: unit.drumLines
                .map(
                  (unitLine) => ChangeNotifierProvider.value(
                    value: unitLine,
                    child: MeasureUnitLineWidget(unitLine: unitLine),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
