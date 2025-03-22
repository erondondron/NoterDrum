import 'package:drums/bar.dart';
import 'package:drums/drum_set.dart';
import 'package:drums/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetMusicWidget extends StatelessWidget {
  const SheetMusicWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetMusicModel>(
      builder: (BuildContext context, SheetMusicModel sheetMusic, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sheetMusic.bars.map((BarModel bar) {
            final isLast = bar == sheetMusic.bars.last;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
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
                  if (isLast)
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
