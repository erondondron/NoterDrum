import 'package:drums/edit_grid/time_signature_custom.dart';
import 'package:drums/models/measure.dart';
import 'package:drums/models/time_signature.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeSignatureWidget extends StatelessWidget {
  const TimeSignatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GrooveMeasure>(
      builder: (BuildContext context, GrooveMeasure measure, _) {
        return PopupMenuButton<TimeSignature>(
          child: Text(measure.timeSignature.label),
          itemBuilder: (BuildContext context) {
            return [
              ...[sixEights, eightEights, sixteenSixteenths].map(
                (TimeSignature timeSignature) => PopupMenuItem(
                  value: timeSignature,
                  child: Text(timeSignature.label),
                  onTap: () => measure.updateTimeSignature(timeSignature),
                ),
              ),
              PopupMenuItem(
                value: measure.timeSignature,
                child: Text("Custom"),
                onTap: () async {
                  var timeSignature = TimeSignature(
                    noteValue: measure.timeSignature.noteValue,
                    measures: measure.timeSignature.measures.toList(),
                  );
                  var accepted = await showDialog<bool?>(
                    context: context,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: timeSignature,
                      child: TimeSignatureCustomizeWindow(),
                    ),
                  );
                  if (accepted == true) {
                    measure.updateTimeSignature(timeSignature);
                  }
                },
              ),
            ];
          },
        );
      },
    );
  }
}
