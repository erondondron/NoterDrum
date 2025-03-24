import 'package:drums/models/sheet_music_bar.dart';
import 'package:drums/models/time_signature.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeSignatureWidget extends StatelessWidget {
  const TimeSignatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetMusicBarModel>(
      builder: (BuildContext context, SheetMusicBarModel bar, _) {
        return PopupMenuButton<TimeSignature>(
          child: Text(bar.timeSignature.label),
          onSelected: (TimeSignature timeSignature) =>
              bar.updateTimeSignature(timeSignature),
          itemBuilder: (BuildContext context) {
            return [sixEights, eightEights, sixteenSixteenths]
                .map(
                  (TimeSignature timeSignature) => PopupMenuItem(
                    value: timeSignature,
                    child: Text(timeSignature.label),
                  ),
                )
                .toList();
          },
        );
      },
    );
  }
}
