import 'package:drums/models/sheet_music.dart';
import 'package:drums/models/sheet_music_bar.dart';
import 'package:drums/widgets/bar.dart';
import 'package:drums/widgets/drum_set.dart';
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
                      padding: EdgeInsets.symmetric(horizontal: 25),
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
