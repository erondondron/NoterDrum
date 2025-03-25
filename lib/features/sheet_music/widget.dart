import 'package:drums/features/sheet_music/bar/models.dart';
import 'package:drums/features/sheet_music/model.dart';
import 'package:drums/features/sheet_music/bar/widget.dart';
import 'package:drums/features/sheet_music/drum_set/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetMusicWidget extends StatelessWidget {
  const SheetMusicWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetMusicModel>(
      builder: (BuildContext context, SheetMusicModel sheetMusic, _) {
        final sheetMusicBars = sheetMusic.bars;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sheetMusicBars.map((SheetMusicBarModel bar) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: <Widget>[
                  ChangeNotifierProvider.value(
                    value: sheetMusic.drumSet,
                    child: const DrumSetWidget(),
                  ),
                  ChangeNotifierProvider.value(
                    value: bar,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: BarWidget(),
                    ),
                  ),
                  if (bar == sheetMusicBars.last)
                    IconButton(
                      icon: const Icon(Icons.add_outlined),
                      onPressed: sheetMusic.addNewBar,
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
