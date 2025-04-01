import 'package:drums/features/sheet_music/measure/model.dart';
import 'package:drums/features/sheet_music/measure/widget.dart';
import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/features/sheet_music/drum_set/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetMusicWidget extends StatelessWidget {
  const SheetMusicWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetMusic>(
      builder: (BuildContext context, SheetMusic sheetMusic, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sheetMusic.measures.map((SheetMusicMeasure measure) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: <Widget>[
                  ChangeNotifierProvider.value(
                    value: sheetMusic.drumSet,
                    child: const DrumSetWidget(),
                  ),
                  ChangeNotifierProvider.value(
                    value: measure,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: SheetMusicMeasureWidget(),
                    ),
                  ),
                  if (measure == sheetMusic.measures.last)
                    IconButton(
                      icon: const Icon(Icons.add_outlined),
                      onPressed: sheetMusic.addNewMeasure,
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
